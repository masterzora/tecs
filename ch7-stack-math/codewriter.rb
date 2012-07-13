class CodeWriter
  def initialize (path)
    @outfile = File.new(path, 'w')
    @count = 0
    @current_file = nil
  end

  def set_filename (name)
    @current_file = name
  end

  def write_arithmetic (command)
    unless ['add', 'sub', 'neg', 'eq', 'gt', 'lt', 'and', 'or', 'not'].include?(command)
      raise Exception, "Expected arithmetic command, got %s" % [command]
    end
    case command
      when 'add'
        @outfile << "@SP\n"
        @outfile << "M=M-1\n"
        @outfile << "A=M\n"
        @outfile << "D=M\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=D+M\n"
      when 'sub'
        @outfile << "@SP\n"
        @outfile << "M=M-1\n"
        @outfile << "A=M\n"
        @outfile << "D=M\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=M-D\n"
      when 'and'
        @outfile << "@SP\n"
        @outfile << "M=M-1\n"
        @outfile << "A=M\n"
        @outfile << "D=M\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=D&M\n"
      when 'or'
        @outfile << "@SP\n"
        @outfile << "M=M-1\n"
        @outfile << "A=M\n"
        @outfile << "D=M\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=D|M\n"
      when 'not'
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=!M\n"
      when 'neg'
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=-M\n"
      when "eq"
        @outfile << "@SP\n"
        @outfile << "M=M-1\n"
        @outfile << "A=M\n"
        @outfile << "D=M\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "D=M-D\n"
        @outfile << "M=0\n"
        @outfile << "@JMP.%s\n" % [@count]
        @outfile << "D;JNE\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=-1\n"
        @outfile << "(JMP.%s)\n" % [@count]
        @count += 1
      when "gt"
        @outfile << "@SP\n"
        @outfile << "M=M-1\n"
        @outfile << "A=M\n"
        @outfile << "D=M\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "D=M-D\n"
        @outfile << "M=0\n"
        @outfile << "@JMP.%s\n" % [@count]
        @outfile << "D;JLE\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=-1\n"
        @outfile << "(JMP.%s)\n" % [@count]
        @count += 1
      when "lt"
        @outfile << "@SP\n"
        @outfile << "M=M-1\n"
        @outfile << "A=M\n"
        @outfile << "D=M\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "D=M-D\n"
        @outfile << "M=0\n"
        @outfile << "@JMP.%s\n" % [@count]
        @outfile << "D;JGE\n"
        @outfile << "@SP\n"
        @outfile << "A=M-1\n"
        @outfile << "M=-1\n"
        @outfile << "(JMP.%s)\n" % [@count]
        @count += 1
    end
  end

  def write_push_pop (command, segment, index)
    unless ['push', 'pop'].include?(command)
      raise Exception, "Expected push or pop, got %s" % [command]
    end
    if command == 'push'
      case segment
        when 'constant'
          @outfile << "@%s\n" % [index]
          @outfile << "D=A\n"
          @outfile << "@SP\n"
          @outfile << "A=M\n"
          @outfile << "M=D\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
        when 'local'
          @outfile << "@LCL\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "A=D+A\n"
          @outfile << "D=M\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
          @outfile << "A=M-1\n"
          @outfile << "M=D\n"
        when 'argument'
          @outfile << "@ARG\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "A=D+A\n"
          @outfile << "D=M\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
          @outfile << "A=M-1\n"
          @outfile << "M=D\n"
        when 'this'
          @outfile << "@THIS\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "A=D+A\n"
          @outfile << "D=M\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
          @outfile << "A=M-1\n"
          @outfile << "M=D\n"
        when 'that'
          @outfile << "@THAT\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "A=D+A\n"
          @outfile << "D=M\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
          @outfile << "A=M-1\n"
          @outfile << "M=D\n"
        when 'pointer'
          @outfile << "@3\n"
          @outfile << "D=A\n"
          @outfile << "@%s\n" % [index]
          @outfile << "A=D+A\n"
          @outfile << "D=M\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
          @outfile << "A=M-1\n"
          @outfile << "M=D\n"
        when 'temp'
          @outfile << "@5\n"
          @outfile << "D=A\n"
          @outfile << "@%s\n" % [index]
          @outfile << "A=D+A\n"
          @outfile << "D=M\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
          @outfile << "A=M-1\n"
          @outfile << "M=D\n"
        when 'static'
          @outfile << "@%s.%s\n" % [@current_file, index]
          @outfile << "D=M\n"
          @outfile << "@SP\n"
          @outfile << "M=M+1\n"
          @outfile << "A=M-1\n"
          @outfile << "M=D\n"
      end
    elsif command == 'pop'
      case segment
        when 'local'
          # pop value off stack
          @outfile << "@SP\n"
          @outfile << "AM=M-1\n"
          @outfile << "D=M\n"
          # store popped value
          @outfile << "@R13\n"
          @outfile << "M=D\n"
          # load local address
          @outfile << "@LCL\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "D=D+A\n"
          # store local address
          @outfile << "@R14\n"
          @outfile << "M=D\n"
          # retrieve popped value
          @outfile << "@R13\n"
          @outfile << "D=M\n"
          # retrieve local address
          @outfile << "@R14\n"
          @outfile << "A=M\n"
          # store popped value in local
          @outfile << "M=D\n"
        when 'argument'
          # pop value off stack
          @outfile << "@SP\n"
          @outfile << "AM=M-1\n"
          @outfile << "D=M\n"
          # store popped value
          @outfile << "@R13\n"
          @outfile << "M=D\n"
          # load local address
          @outfile << "@ARG\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "D=D+A\n"
          # store local address
          @outfile << "@R14\n"
          @outfile << "M=D\n"
          # retrieve popped value
          @outfile << "@R13\n"
          @outfile << "D=M\n"
          # retrieve local address
          @outfile << "@R14\n"
          @outfile << "A=M\n"
          # store popped value in local
          @outfile << "M=D\n"
        when 'this'
          # pop value off stack
          @outfile << "@SP\n"
          @outfile << "AM=M-1\n"
          @outfile << "D=M\n"
          # store popped value
          @outfile << "@R13\n"
          @outfile << "M=D\n"
          # load local address
          @outfile << "@THIS\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "D=D+A\n"
          # store local address
          @outfile << "@R14\n"
          @outfile << "M=D\n"
          # retrieve popped value
          @outfile << "@R13\n"
          @outfile << "D=M\n"
          # retrieve local address
          @outfile << "@R14\n"
          @outfile << "A=M\n"
          # store popped value in local
          @outfile << "M=D\n"
        when 'that'
          # pop value off stack
          @outfile << "@SP\n"
          @outfile << "AM=M-1\n"
          @outfile << "D=M\n"
          # store popped value
          @outfile << "@R13\n"
          @outfile << "M=D\n"
          # load local address
          @outfile << "@THAT\n"
          @outfile << "D=M\n"
          @outfile << "@%s\n" % [index]
          @outfile << "D=D+A\n"
          # store local address
          @outfile << "@R14\n"
          @outfile << "M=D\n"
          # retrieve popped value
          @outfile << "@R13\n"
          @outfile << "D=M\n"
          # retrieve local address
          @outfile << "@R14\n"
          @outfile << "A=M\n"
          # store popped value in local
          @outfile << "M=D\n"
        when 'pointer'
          # pop value off stack
          @outfile << "@SP\n"
          @outfile << "AM=M-1\n"
          @outfile << "D=M\n"
          # store popped value
          @outfile << "@R13\n"
          @outfile << "M=D\n"
          # load local address
          @outfile << "@3\n"
          @outfile << "D=A\n"
          @outfile << "@%s\n" % [index]
          @outfile << "D=D+A\n"
          # store local address
          @outfile << "@R14\n"
          @outfile << "M=D\n"
          # retrieve popped value
          @outfile << "@R13\n"
          @outfile << "D=M\n"
          # retrieve local address
          @outfile << "@R14\n"
          @outfile << "A=M\n"
          # store popped value in local
          @outfile << "M=D\n"
        when 'temp'
          # pop value off stack
          @outfile << "@SP\n"
          @outfile << "AM=M-1\n"
          @outfile << "D=M\n"
          # store popped value
          @outfile << "@R13\n"
          @outfile << "M=D\n"
          # load local address
          @outfile << "@5\n"
          @outfile << "D=A\n"
          @outfile << "@%s\n" % [index]
          @outfile << "D=D+A\n"
          # store local address
          @outfile << "@R14\n"
          @outfile << "M=D\n"
          # retrieve popped value
          @outfile << "@R13\n"
          @outfile << "D=M\n"
          # retrieve local address
          @outfile << "@R14\n"
          @outfile << "A=M\n"
          # store popped value in local
          @outfile << "M=D\n"
        when 'static'
          @outfile << "@SP\n"
          @outfile << "AM=M-1\n"
          @outfile << "D=M\n"
          @outfile << "@%s.%s\n" % [@current_file, index]
          @outfile << "M=D\n"
      end
    end
  end

  def close
    @outfile.close
  end
end
