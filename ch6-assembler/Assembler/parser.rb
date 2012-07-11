class Parser
  def initialize (path)
    @asmlines = IO.readlines(path)
    # strip out white space
    @asmlines.collect! do |line|
      line.gsub(/\s/, '')
    end
    # strip out comments
    @asmlines.collect! do |line|
      line.gsub(/\/\/.*$/, '')
    end
    @asmlines.reject! do |line|
      line == ''
    end
    @current_command_index = -1
    @current_command = nil
  end

  def reset
    @current_command_index = -1
    @current_command = nil
  end

  def more_commands?
    @current_command_index + 1 < @asmlines.length
  end

  def advance
    unless more_commands?
      raise Exception, "Must be more commands to advance"
    end
    @current_command_index += 1
    @current_command = @asmlines[@current_command_index]
  end

  def command_type
    unless @current_command
      raise Exception, "Must have current command to have a type"
    end
    if @current_command[0] == '@'
      :a_command
    elsif @current_command[0] == '('
      :l_command
    else
      :c_command
    end
  end

  def symbol
    type = command_type
    if type == :c_command
      raise Exception, "Current command must be A or L command"
    elsif type == :a_command
      @current_command[1..-1]
    elsif type == :l_command
      @current_command[1..-2]
    end
  end

  def dest
    type = command_type
    unless type == :c_command
      raise Exception, "Current command must be C command"
    end
    equals = @current_command.index('=')
    if equals
      @current_command[0..equals-1]
    else
      'null'
    end
  end

  def comp
    type = command_type
    unless type == :c_command
      raise Exception, "Current command must be C command"
    end
    equals = @current_command.index('=') || -1
    semicolon = @current_command.index(';') || 0
    @current_command[equals + 1..semicolon - 1]
  end

  def jump
    type = command_type
    unless type == :c_command
      raise Exception, "Current command must be C command"
    end
    semicolon = @current_command.index(';')
    if semicolon
      @current_command[semicolon + 1..-1]
    else
      'null'
    end
  end
end
