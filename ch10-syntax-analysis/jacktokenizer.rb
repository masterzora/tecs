class JackTokenizer
  def initialize (path)
    jacksrc = IO.read(path)
    # strip out /**/-style comments
    jacksrc.gsub!(/\/\*.*?\*\//m, '')
    @jacklines = jacksrc.split("\n")
    # strip out //-style comments
    @jacklines.collect! do |line|
      line.gsub(/\/\/.*$/, '')
    end
    # split into tokens
    @jacklines.collect! do |line|
      line.split(/(".*?"|[{}()\[\].,;+\-*\/&|<>=~]|\s+)/)
    end
    @jacklines.flatten!
    # remove empty tokens
    @jacklines.reject! do |token|
      token.match(/^\s*$/)
    end
    @current_token = nil
    @current_token_index = -1
  end

  def more_tokens?
    @current_token_index + 1 < @jacklines.length
  end

  def advance
    @current_token_index += 1
    @current_token = @jacklines[@current_token_index]
  end

  def backtrack
    @current_token_index -= 1
    @current_token = @jacklines[@current_token_index]
  end

  def token_type
    if ['class', 'method', 'function', 'constructor', 'int', 'boolean', 'char', 'void', 'var', 'static', 'field', 'let', 'do', 'if', 'else', 'while', 'return', 'true', 'false', 'null', 'this'].include?(@current_token)
      :keyword
    elsif ['{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '|', '<', '>', '=', '~'].include?(@current_token)
      :symbol
    elsif @current_token[0] == '"' and @current_token[-1] == '"'
      :string_const
    elsif @current_token =~ /^\d+$/
      :int_const
    elsif @current_token =~ /^[A-Za-z_][A-Za-z0-9_]*$/
      :identifier
    else
      raise Exception, "Invalid token \"%s\"" % [@current_token]
    end
  end

  def keyword
    unless token_type == :keyword
      raise Exception, "Keyword expected, got %s" % [token_type]
    end
    case @current_token
      when 'class'
        :class
      when 'method'
        :method
      when 'function'
        :function
      when 'constructor'
        :constructor
      when 'int'
        :int
      when 'boolean'
        :boolean
      when 'char'
        :char
      when 'void'
        :void
      when 'var'
        :var
      when 'static'
        :static
      when 'field'
        :field
      when 'let'
        :let
      when 'do'
        :do
      when 'if'
        :if
      when 'else'
        :else
      when 'while'
        :while
      when 'return'
        :return
      when 'true'
        :true
      when 'false'
        :false
      when 'null'
        :null
      when 'this'
        :this
    end
  end

  def symbol
    unless token_type == :symbol
      raise Exception, "Expected symbol, got %s" % [token_type]
    end
    @current_token
  end

  def identifier
    unless token_type == :identifier
      raise Exception, "Expected identifier, got %s" % [token_type]
    end
    @current_token
  end

  def int_val
    unless token_type == :int_const
      raise Exception, "Expected int constant, got %s" % [token_type]
    end
    @current_token.to_i
  end

  def string_val
    unless token_type == :string_const
      raise Exception, "Expected string constant, got %s" % [token_type]
    end
    @current_token[1...-1]
  end
end
