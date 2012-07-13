class Parser
  def initialize (path)
    @vmlines = IO.readlines(path)
    # strip out comments
    @vmlines.collect! do |line|
      line.gsub(/\/\/.*$/, '')
    end
    # tokenise each line
    @vmlines.collect! do |line|
      line.split
    end
    # strip out empty lines
    @vmlines.reject! do |line|
      line == []
    end
    @current_line_index = -1
    @current_line = nil
  end

  def more_commands?
    @current_line_index + 1 < @vmlines.length
  end

  def advance
    unless more_commands?
      raise Exception, 'Must have more commands to advance'
    end
    @current_line_index += 1
    @current_line = @vmlines[@current_line_index]
  end

  def command_type
    case @current_line[0]
    when 'push'
      :c_push
    when 'pop'
      :c_pop
    when 'label'
      :c_label
    when 'goto'
      :c_goto
    when 'if-goto'
      :c_if
    when 'function'
      :c_function
    when 'call'
      :c_return
    when 'return'
      :c_call
    when 'add', 'sub', 'neg', 'eq', 'gt', 'lt', 'and', 'or', 'not'
      :c_arithmetic
    end
  end

  def arg1
    if command_type == :c_return
      raise Exception, "Return command has no arguments"
    elsif command_type == :c_arithmetic
      @current_line[0]
    else
      @current_line[1]
    end
  end

  def arg2
    unless [:c_push, :c_pop, :c_function, :c_call].include?(command_type)
      raise Exception, "Only push, pop, function, and call commands have second argument"
    end
    @current_line[2]
  end
end
