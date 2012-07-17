require_relative 'jacktokenizer'
require_relative 'symboltable'
require_relative 'vmwriter'

class CompilationEngine
  def initialize (inpath, outpath)
    @tokenizer = JackTokenizer::new(inpath)
    @tokenizer.advance
    @symboltable = SymbolTable::new
    @writer = VMWriter::new(outpath)
    @label_count = 0
    @class = nil
    @field_count = 0
  end

  def compile_class
    @tokenizer.advance
    @class = @tokenizer.identifier
    @tokenizer.advance
    @tokenizer.advance
    while @tokenizer.token_type == :keyword and [:static, :field].include?(@tokenizer.keyword)
      compile_class_var_dec
    end
    while @tokenizer.token_type == :keyword and [:constructor, :function, :method].include?(@tokenizer.keyword)
      compile_subroutine
    end
    @tokenizer.advance
    @writer.close
    if @tokenizer.more_tokens?
      raise Exception, "Done parsing but more tokens remain"
    end
  end

  def compile_class_var_dec
    category = @tokenizer.keyword
    if category == :field
      @field_count += 1
    end
    @tokenizer.advance
    if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
      type = @tokenizer.keyword
    else
      type = @tokenizer.identifier
    end
    @tokenizer.advance
    name = @tokenizer.identifier
    @symboltable.define(name, type, category) 
    @tokenizer.advance
    while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
      @tokenizer.advance
      if category == :field
        @field_count += 1
      end
      name = @tokenizer.identifier
      @symboltable.define(name, type, category) 
      @tokenizer.advance
    end
    @tokenizer.advance
  end

  def compile_subroutine
    @symboltable.start_subroutine
    subtype = @tokenizer.keyword
    if subtype == :method
      @symboltable.define('this', @class, :arg)
    end
    @tokenizer.advance
    @tokenizer.advance
    name = "%s.%s" % [@class, @tokenizer.identifier]
    @tokenizer.advance
    @tokenizer.advance
    compile_parameter_list
    @tokenizer.advance
    @tokenizer.advance
    local_count = 0
    while @tokenizer.token_type == :keyword and @tokenizer.keyword == :var
      local_count += compile_var_dec
    end
    @writer.write_function(name, local_count)
    if subtype == :method
      @writer.write_push('argument', 0)
      @writer.write_pop('pointer', 0)
    elsif subtype == :constructor
      @writer.write_push('constant', @field_count)
      @writer.write_call('Memory.alloc', 1)
      @writer.write_pop('pointer', 0)
    end
    compile_statements
    @tokenizer.advance
  end

  def compile_parameter_list
    unless @tokenizer.token_type == :symbol and @tokenizer.symbol == ')'
      if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
        type = @tokenizer.keyword
      else
        type = @tokenizer.identifier
      end
      @tokenizer.advance
      name = @tokenizer.identifier
      @symboltable.define(name, type, :arg)
      @tokenizer.advance
      while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
        @tokenizer.advance
        if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
          type = @tokenizer.keyword
        else
          type = @tokenizer.identifier
        end
        @tokenizer.advance
        name = @tokenizer.identifier
        @symboltable.define(name, type, :arg)
        @tokenizer.advance
      end
    end
  end

  def compile_var_dec
    num_locals = 0
    @tokenizer.advance
    if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
      type = @tokenizer.keyword
    else
      type = @tokenizer.identifier
    end
    @tokenizer.advance
    name = @tokenizer.identifier
    @symboltable.define(name, type, :var)
    num_locals += 1
    @tokenizer.advance

    while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
      @tokenizer.advance
      name = @tokenizer.identifier
      @symboltable.define(name, type, :var)
      num_locals += 1
      @tokenizer.advance
    end
    @tokenizer.advance
    num_locals
  end

  def compile_statements
    while @tokenizer.token_type == :keyword and  [:let, :if, :while, :do, :return].include?(@tokenizer.keyword) do
      case @tokenizer.keyword
        when :let
          compile_let
        when :if
          compile_if
        when :while
          compile_while
        when :do
          compile_do
        when :return
          compile_return
      end
    end
  end

  def compile_do
    @tokenizer.advance
    compile_subroutine_call
    @tokenizer.advance
    @writer.write_pop('temp', 0)
  end

  def compile_let
    if @tokenizer.token_type == :keyword and @tokenizer.keyword == :let
      @tokenizer.advance
    end
    if @tokenizer.token_type == :identifier
      name = @tokenizer.identifier
      symbol = [@symboltable.type_of(name), @symboltable.kind_of(name), @symboltable.index_of(name)]
      @tokenizer.advance
    end
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '['
      @tokenizer.advance
      compile_expression
      case symbol[1]
        when :static
          @writer.write_push('static', symbol[2])
        when :arg
          @writer.write_push('argument', symbol[2])
        when :var
          @writer.write_push('local', symbol[2])
        when :field
          @writer.write_push('this', symbol[2])
      end
      @writer.write_arithmetic('add')
      @tokenizer.advance
      symbol[1] = :pointer
      symbol[2] = 1
    end
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '='
      @tokenizer.advance
    end
    compile_expression
    case symbol[1]
      when :static
        @writer.write_pop('static', symbol[2])
      when :arg
        @writer.write_pop('argument', symbol[2])
      when :var
        @writer.write_pop('local', symbol[2])
      when :field
        @writer.write_pop('this', symbol[2])
      when :pointer
        @writer.write_pop('temp', 0)
        @writer.write_pop('pointer', 1)
        @writer.write_push('temp', 0)
        @writer.write_pop('that',0)
    end
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == ';'
      @tokenizer.advance
    end
  end

  def compile_while
    label = @label_count
    @label_count += 1
    @tokenizer.advance
    @tokenizer.advance
    @writer.write_label('WHILE_BEG_%s' % [label])
    compile_expression
    @writer.write_arithmetic('not')
    @writer.write_if('WHILE_END_%s' % [label])
    @tokenizer.advance
    @tokenizer.advance
    compile_statements
    @tokenizer.advance
    @writer.write_goto('WHILE_BEG_%s' % [label])
    @writer.write_label('WHILE_END_%s' % [label])
  end

  def compile_return
    @tokenizer.advance
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == ';'
      @writer.write_push('constant', 0)
    else
      compile_expression
    end
    @writer.write_return
    @tokenizer.advance
  end

  def compile_if
    label = @label_count
    @label_count += 1
    @tokenizer.advance
    @tokenizer.advance
    compile_expression
    @tokenizer.advance
    @writer.write_if('IF_TRUE_%s' % [label])
    @writer.write_goto('IF_FALSE_%s' % [label])
    @writer.write_label('IF_TRUE_%s' % [label])
    @tokenizer.advance
    compile_statements
    @tokenizer.advance
    if @tokenizer.token_type == :keyword and @tokenizer.keyword == :else
      @writer.write_goto('IF_END_%s' % [label])
      @writer.write_label('IF_FALSE_%s' % [label])
      @tokenizer.advance
      @tokenizer.advance
      compile_statements
      @tokenizer.advance
      @writer.write_label('IF_END_%s' % [label])
    else
      @writer.write_label('IF_FALSE_%s' % [label])
    end
  end

  def compile_expression
    compile_term
    while @tokenizer.token_type == :symbol and ['+', '-', '*', '/', '&', '|', '<', '>', '='].include?(@tokenizer.symbol)
      op = @tokenizer.symbol
      @tokenizer.advance
      compile_term
      case op
        when '+'
          @writer.write_arithmetic('add')
        when '-'
          @writer.write_arithmetic('sub')
        when '*'
          @writer.write_call('Math.multiply', 2)
        when '/'
          @writer.write_call('Math.divide', 2)
        when '&'
          @writer.write_arithmetic('and')
        when '|'
          @writer.write_arithmetic('or')
        when '<'
          @writer.write_arithmetic('lt')
        when '>'
          @writer.write_arithmetic('gt')
        when '='
          @writer.write_arithmetic('eq')
      end
    end
  end

  def compile_term
    case @tokenizer.token_type
      when :int_const
        @writer.write_push('constant', @tokenizer.int_val)
        @tokenizer.advance
      when :string_const
        @writer.write_push('constant', @tokenizer.string_val.length)
        @writer.write_call('String.new', 1)
        @tokenizer.string_val.each_char do |c|
          @writer.write_push('constant', c.ord)
          @writer.write_call('String.appendChar', 2)
        end
        @tokenizer.advance
      when :keyword
        case @tokenizer.keyword
          when :true
            @writer.write_push('constant', 0)
            @writer.write_arithmetic('not')
          when :false
            @writer.write_push('constant', 0)
          when :null
            @writer.write_push('constant', 0)
          when :this
            @writer.write_push('pointer', 0)
        end
        @tokenizer.advance
      when :symbol
        if @tokenizer.symbol == '('
          @tokenizer.advance
          compile_expression
          @tokenizer.advance
        elsif @tokenizer.symbol == '~'
          @tokenizer.advance
          compile_term
          @writer.write_arithmetic('not')
        elsif @tokenizer.symbol == '-'
          @tokenizer.advance
          compile_term
          @writer.write_arithmetic('neg')
        end
      when :identifier
        @tokenizer.advance
        if @tokenizer.token_type == :symbol and (@tokenizer.symbol == '.' or @tokenizer.symbol == '(')
          @tokenizer.backtrack
          compile_subroutine_call
        elsif @tokenizer.token_type == :symbol and @tokenizer.symbol == '['
          @tokenizer.backtrack
          name = @tokenizer.identifier
          symbol = [@symboltable.type_of(name), @symboltable.kind_of(name), @symboltable.index_of(name)]
          @tokenizer.advance
          @tokenizer.advance
          compile_expression
          case symbol[1]
            when :static
              @writer.write_push('static', symbol[2])
            when :arg
              @writer.write_push('argument', symbol[2])
            when :var
              @writer.write_push('local', symbol[2])
            when :field
              @writer.write_push('this', symbol[2])
          end
          @writer.write_arithmetic('add')
          @writer.write_pop('pointer', 1)
          @writer.write_push('that', 0)
          @tokenizer.advance
        else
          @tokenizer.backtrack
          name = @tokenizer.identifier
          symbol = [@symboltable.type_of(name), @symboltable.kind_of(name), @symboltable.index_of(name)]
          case symbol[1]
            when :static
              @writer.write_push('static', symbol[2])
            when :arg
              @writer.write_push('argument', symbol[2])
            when :var
              @writer.write_push('local', symbol[2])
            when :field
              @writer.write_push('this', symbol[2])
          end
          @tokenizer.advance
        end
    end
  end

  def compile_expression_list
    expression_count = 0
    unless @tokenizer.token_type == :symbol and @tokenizer.symbol == ')'
      compile_expression
      expression_count += 1
      while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
        @tokenizer.advance
        compile_expression
        expression_count += 1
      end
    end
    expression_count
  end

  def compile_subroutine_call
    name = @tokenizer.identifier
    @tokenizer.advance
    method = true
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '.'
      kind = @symboltable.kind_of(name)
      if kind == :none
        caller_class = name
        method = false
      else
        caller_class = @symboltable.type_of(name)
        segment = @symboltable.kind_of(name)
        index = @symboltable.index_of(name)
      end
    else
      segment = :pointer
      index = 0
      caller_class = @class
    end
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '.'
      @tokenizer.advance
      name = @tokenizer.identifier
      @tokenizer.advance
    end
    @tokenizer.advance
    if method
      case segment
        when :field
          @writer.write_push('this', index)
        when :arg
          @writer.write_push('argument', index)
        when :static
          @writer.write_push('static', index)
        when :var
          @writer.write_push('local', index)
        when :pointer
          @writer.write_push('pointer', 0)
        else
          p segment
      end
    end
    n_args = compile_expression_list
    if method
      n_args += 1
    end
    @writer.write_call('%s.%s' % [caller_class, name], n_args)
    @tokenizer.advance
  end
end
