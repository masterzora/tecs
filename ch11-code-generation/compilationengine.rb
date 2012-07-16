require_relative 'jacktokenizer'
require_relative 'symboltable'

class CompilationEngine
  def initialize (inpath, outpath)
    @tokenizer = JackTokenizer::new(inpath)
    @tokenizer.advance
    @outfile = File.new(outpath, 'w')
    @symboltable = SymbolTable::new
  end

  def compile_class
    @outfile << "<class>\n"
    @outfile << "<keyword>class</keyword>\n"
    @tokenizer.advance
    @outfile << "<identifier>\n<name>%s</name>\n<category>class</category>\n<defined>defined</defined>\n</identifier>\n" % [@tokenizer.identifier]
    @tokenizer.advance
    @outfile << "<symbol>{</symbol>\n"
    @tokenizer.advance
    while @tokenizer.token_type == :keyword and [:static, :field].include?(@tokenizer.keyword)
      compile_class_var_dec
    end
    while @tokenizer.token_type == :keyword and [:constructor, :function, :method].include?(@tokenizer.keyword)
      compile_subroutine
    end
    @outfile << "<symbol>}</symbol>\n"
    @tokenizer.advance
    @outfile << "</class>\n"
    @outfile.close
    if @tokenizer.more_tokens?
      raise Exception, "Done parsing but more tokens remain"
    end
  end

  def compile_class_var_dec
    @outfile << "<classVarDec>\n"
    @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
    category = @tokenizer.keyword
    @tokenizer.advance
    if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
      @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
      type = @tokenizer.keyword
    else
      @outfile << "<identifier>\n<name>%s</name>\n<category>class</category>\n<defined>used</defined>\n</identifier>\n" % [@tokenizer.identifier]
      type = @tokenizer.identifier
    end
    @tokenizer.advance
    name = @tokenizer.identifier
    @symboltable.define(name, type, category) 
    @outfile << "<identifier>\n"
    @outfile << "<name>%s</name>\n" % [name]
    @outfile << "<category>%s</category>\n" % [category]
    @outfile << "<defined>defined</defined>\n"
    @outfile << "<kind>%s</kind>\n" % [@symboltable.kind_of(name)]
    @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
    @outfile << "</identifier>\n"
    @tokenizer.advance
    while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
      @outfile << "<symbol>,</symbol>\n"
      @tokenizer.advance
      name = @tokenizer.identifier
      @symboltable.define(name, type, category) 
      @outfile << "<identifier>\n"
      @outfile << "<name>%s</name>\n" % [name]
      @outfile << "<category>%s</category>\n" % [category]
      @outfile << "<defined>defined</defined>\n"
      @outfile << "<kind>%s</kind>\n" % [@symboltable.kind_of(name)]
      @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
      @outfile << "</identifier>\n"
      @tokenizer.advance
    end
    @outfile << "<symbol>;</symbol>\n"
    @tokenizer.advance
    @outfile << "</classVarDec>\n"
  end

  def compile_subroutine
    @symboltable.start_subroutine
    @outfile << "<subroutineDec>\n"
    @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
    @tokenizer.advance
    if @tokenizer.token_type == :keyword
      @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
    else
      @outfile << "<identifier>\n<name>%s</name>\n<category>class</category>\n<defined>used</defined>\n</identifier>\n" % [@tokenizer.identifier]
    end
    @tokenizer.advance
    @outfile << "<identifier>\n<name>%s</name>\n<category>subroutine</category>\n<defined>defined</defined>\n</identifier>\n" % [@tokenizer.identifier]
    @tokenizer.advance
    @outfile << "<symbol>(</symbol>\n" % [@tokenizer.symbol]
    @tokenizer.advance
    compile_parameter_list
    @outfile << "<symbol>)</symbol>\n" % [@tokenizer.symbol]
    @tokenizer.advance
    @outfile << "<subroutineBody>\n"
    @outfile << "<symbol>{</symbol>\n"
    @tokenizer.advance
    while @tokenizer.token_type == :keyword and @tokenizer.keyword == :var
      compile_var_dec
    end
    compile_statements
    @outfile << "<symbol>}</symbol>\n"
    @tokenizer.advance
    @outfile << "</subroutineBody>\n"
    @outfile << "</subroutineDec>\n"
  end

  def compile_parameter_list
    @outfile << "<parameterList>\n"
    unless @tokenizer.token_type == :symbol and @tokenizer.symbol == ')'
      if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
        @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
        type = @tokenizer.keyword
      else
        @outfile << "<identifier>\n<name>%s</name>\n<category>class</category>\n<defined>used</defined>\n</identifier>\n" % [@tokenizer.identifier]
        type = @tokenizer.identifier
      end
      @tokenizer.advance
      name = @tokenizer.identifier
      @symboltable.define(name, type, :arg)
      @outfile << "<identifier>\n"
      @outfile << "<name>%s</name>\n" % [name]
      @outfile << "<category>arg</category>\n"
      @outfile << "<defined>defined</defined>\n"
      @outfile << "<kind>:arg</kind>\n"
      @outfile << "<index>%s</index>\n" % @symboltable.index_of(name)
      @outfile << "</identifier>\n"
      @tokenizer.advance
      while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
        @outfile << "<symbol>,</symbol>\n"
        @tokenizer.advance
        if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
          @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
          type = @tokenizer.keyword
        else
          @outfile << "<identifier>\n<name>%s</name>\n<category>class</category>\n<defined>used</defined>\n</identifier>\n" % [@tokenizer.identifier]
          type = @tokenizer.identifier
        end
        @tokenizer.advance
        name = @tokenizer.identifier
        @symboltable.define(name, type, :arg)
        @outfile << "<identifier>\n"
        @outfile << "<name>%s</name>\n" % [name]
        @outfile << "<category>arg</category>\n"
        @outfile << "<defined>defined</defined>\n"
        @outfile << "<kind>arg</kind>\n"
        @outfile << "<index>%s</index>\n" % @symboltable.index_of(name)
        @outfile << "</identifier>\n"
        @tokenizer.advance
      end
    end
    @outfile << "</parameterList>\n"
  end

  def compile_var_dec
    @outfile << "<varDec>\n"
    @outfile << "<keyword>var</keyword>\n"
    @tokenizer.advance
    if @tokenizer.token_type == :keyword and [:int, :char, :boolean].include?(@tokenizer.keyword)
      @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
      type = @tokenizer.keyword
    else
      @outfile << "<identifier>\n<name>%s</name>\n<category>class</category>\n<defined>used</defined>\n</identifier>\n" % [@tokenizer.identifier]
      type = @tokenizer.identifier
    end
    @tokenizer.advance
    name = @tokenizer.identifier
    @symboltable.define(name, type, :var)
    @outfile << "<identifier>\n"
    @outfile << "<name>%s</name>\n" % [name]
    @outfile << "<category>var</category>\n"
    @outfile << "<defined>defined</defined>\n"
    @outfile << "<kind>var</kind>\n"
    @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
    @outfile << "</identifier>\n"
    @tokenizer.advance

    while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
      @outfile << "<symbol>,</symbol>\n"
      @tokenizer.advance
      name = @tokenizer.identifier
      @symboltable.define(name, type, :var)
      @outfile << "<identifier>\n"
      @outfile << "<name>%s</name>\n" % [name]
      @outfile << "<category>var</category>\n"
      @outfile << "<defined>defined</defined>\n"
      @outfile << "<kind>var</kind>\n"
      @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
      @outfile << "</identifier>\n"
      @tokenizer.advance
    end
    @outfile << "<symbol>;</symbol>\n"
    @tokenizer.advance
    @outfile << "</varDec>\n"
  end

  def compile_statements
    @outfile << "<statements>\n"
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
    @outfile << "</statements>\n"
  end

  def compile_do
    @outfile << "<doStatement>\n"
    @outfile << "<keyword>do</keyword>\n"
    @tokenizer.advance
    compile_subroutine_call
    @outfile << "<symbol>;</symbol>\n"
    @tokenizer.advance
    @outfile << "</doStatement>\n"
  end

  def compile_let
    @outfile << "<letStatement>\n"
    if @tokenizer.token_type == :keyword and @tokenizer.keyword == :let
      @outfile << "<keyword>let</keyword>\n"
      @tokenizer.advance
    end
    if @tokenizer.token_type == :identifier
      name = @tokenizer.identifier
      @outfile << "<identifier>\n"
      @outfile << "<name>%s</name>\n" % [name]
      @outfile << "<category>%s</category>\n" % [@symboltable.kind_of(name)]
      @outfile << "<defined>used</defined>\n"
      @outfile << "<kind>%s</kind>\n" % [@symboltable.kind_of(name)]
      @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
      @outfile << "</identifier>\n"
      @tokenizer.advance
    end
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '['
      @outfile << "<symbol>[</symbol>\n"
      @tokenizer.advance
      compile_expression
      @outfile << "<symbol>]</symbol>\n"
      @tokenizer.advance
    end
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '='
      @outfile << "<symbol>=</symbol>\n"
      @tokenizer.advance
    end
    compile_expression
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == ';'
      @outfile << "<symbol>;</symbol>\n"
      @tokenizer.advance
    end
    @outfile << "</letStatement>\n"
  end

  def compile_while
    @outfile << "<whileStatement>\n"
    @outfile << "<keyword>while</keyword>\n"
    @tokenizer.advance
    @outfile << "<symbol>(</symbol>\n"
    @tokenizer.advance
    compile_expression
    @outfile << "<symbol>)</symbol>\n"
    @tokenizer.advance
    @outfile << "<symbol>{</symbol>\n"
    @tokenizer.advance
    compile_statements
    @outfile << "<symbol>}</symbol>\n"
    @tokenizer.advance
    @outfile << "</whileStatement>\n"
  end

  def compile_return
    @outfile << "<returnStatement>\n"
    @outfile << "<keyword>return</keyword>\n"
    @tokenizer.advance
    unless @tokenizer.token_type == :symbol and @tokenizer.symbol == ';'
      compile_expression
    end
    @outfile << "<symbol>;</symbol>\n"
    @tokenizer.advance
    @outfile << "</returnStatement>\n"
  end

  def compile_if
    @outfile << "<ifStatement>\n"
    @outfile << "<keyword>if</keyword>\n"
    @tokenizer.advance
    @outfile << "<symbol>(</symbol>\n"
    @tokenizer.advance
    compile_expression
    @outfile << "<symbol>)</symbol>\n"
    @tokenizer.advance
    @outfile << "<symbol>{</symbol>\n"
    @tokenizer.advance
    compile_statements
    @outfile << "<symbol>}</symbol>\n"
    @tokenizer.advance
    if @tokenizer.token_type == :keyword and @tokenizer.keyword == :else
      @outfile << "<keyword>else</keyword>\n"
      @tokenizer.advance
      @outfile << "<symbol>{</symbol>\n"
      @tokenizer.advance
      compile_statements
      @outfile << "<symbol>}</symbol>\n"
      @tokenizer.advance
    end
    @outfile << "</ifStatement>\n"
  end

  def compile_expression
    @outfile << "<expression>\n"
    compile_term
    while @tokenizer.token_type == :symbol and ['+', '-', '*', '/', '&', '|', '<', '>', '='].include?(@tokenizer.symbol)
      @outfile << "<symbol>"
      case @tokenizer.symbol
        when '&'
          @outfile << '&amp;'
        when '<'
          @outfile << '&lt;'
        when '>'
          @outfile << '&gt;'
        else
          @outfile << @tokenizer.symbol
      end
      @outfile << "</symbol>\n"
      @tokenizer.advance
      compile_term
    end
    @outfile << "</expression>\n"
  end

  def compile_term
    @outfile << "<term>\n"
    case @tokenizer.token_type
      when :int_const
        @outfile << "<integerConstant>%s</integerConstant>\n" % [@tokenizer.int_val]
        @tokenizer.advance
      when :string_const
        @outfile << "<stringConstant>%s</stringConstant>\n" % [@tokenizer.string_val]
        @tokenizer.advance
      when :keyword
        @outfile << "<keyword>%s</keyword>\n" % [@tokenizer.keyword]
        @tokenizer.advance
      when :symbol
        if @tokenizer.symbol == '('
          @outfile << "<symbol>(</symbol>\n"
          @tokenizer.advance
          compile_expression
          @outfile << "<symbol>)</symbol>\n"
          @tokenizer.advance
        elsif @tokenizer.symbol == '~' or @tokenizer.symbol == '-'
          @outfile << "<symbol>%s</symbol>\n" % [@tokenizer.symbol]
          @tokenizer.advance
          compile_term
        end
      when :identifier
        @tokenizer.advance
        if @tokenizer.token_type == :symbol and (@tokenizer.symbol == '.' or @tokenizer.symbol == '(')
          @tokenizer.backtrack
          compile_subroutine_call
        elsif @tokenizer.token_type == :symbol and @tokenizer.symbol == '['
          @tokenizer.backtrack
          name = @tokenizer.identifier
          @outfile << "<identifier>\n"
          @outfile << "<name>%s</name>\n" % [name]
          @outfile << "<category>%s</category>\n" % [@symboltable.kind_of(name)]
          @outfile << "<defined>used</defined>\n"
          @outfile << "<kind>%s</kind>\n" % [@symboltable.kind_of(name)]
          @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
          @outfile << "</identifier>\n"
          @tokenizer.advance
          @outfile << "<symbol>[</symbol>\n"
          @tokenizer.advance
          compile_expression
          @outfile << "<symbol>]</symbol>\n"
          @tokenizer.advance
        else
          @tokenizer.backtrack
          name = @tokenizer.identifier
          @outfile << "<identifier>\n"
          @outfile << "<name>%s</name>\n" % [name]
          @outfile << "<category>%s</category>\n" % [@symboltable.kind_of(name)]
          @outfile << "<defined>used</defined>\n"
          @outfile << "<kind>%s</kind>\n" % [@symboltable.kind_of(name)]
          @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
          @outfile << "</identifier>\n"
          @tokenizer.advance
        end
    end
    @outfile << "</term>\n"
  end

  def compile_expression_list
    @outfile << "<expressionList>\n"
    unless @tokenizer.token_type == :symbol and @tokenizer.symbol == ')'
      compile_expression
      while @tokenizer.token_type == :symbol and @tokenizer.symbol == ','
        @outfile << "<symbol>,</symbol>\n"
        @tokenizer.advance
        compile_expression
      end
    end
    @outfile << "</expressionList>\n"
  end

  def compile_subroutine_call
    name = @tokenizer.identifier
    @tokenizer.advance
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '.'
      kind = @symboltable.kind_of(name)
      if kind == :none
        @outfile << "<identifier>\n"
        @outfile << "<name>%s</name>\n" % [name]
        @outfile << "<category>class</category>\n"
        @outfile << "<defined>used</defined>\n"
        @outfile << "</identifier>\n"
      else
        @outfile << "<identifier>\n"
        @outfile << "<name>%s</name>\n" % [name]
        @outfile << "<category>%s</category>\n" % [kind]
        @outfile << "<defined>used</defined>\n"
        @outfile << "<kind>%s</kind>\n" % [kind]
        @outfile << "<index>%s</index>\n" % [@symboltable.index_of(name)]
        @outfile << "</identifier>\n"
      end
    else
      @outfile << "<identifier>\n"
      @outfile << "<name>%s</name>\n" % [name]
      @outfile << "<category>subroutine</category>\n"
      @outfile << "<defined>used</defined>\n"
      @outfile << "</identifier>\n"
    end
    if @tokenizer.token_type == :symbol and @tokenizer.symbol == '.'
      @outfile << "<symbol>.</symbol>\n"
      @tokenizer.advance
      name = @tokenizer.identifier
      @outfile << "<identifier>\n"
      @outfile << "<name>%s</name>\n" % [name]
      @outfile << "<category>subroutine</category>\n"
      @outfile << "<defined>used</defined>\n"
      @outfile << "</identifier>\n"
      @tokenizer.advance
    end
    @outfile << "<symbol>(</symbol>\n"
    @tokenizer.advance
    compile_expression_list
    @outfile << "<symbol>)</symbol>\n"
    @tokenizer.advance
  end
end
