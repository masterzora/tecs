class VMWriter
  def initialize (outpath)
    @outfile = File.new(outpath, 'w')
  end

  def write_push (segment, index)
    @outfile << "push %s %s\n" % [segment, index]
  end

  def write_pop (segment, index)
    @outfile << "pop %s %s\n" % [segment, index]
  end

  def write_arithmetic (command)
    @outfile << command << "\n"
  end

  def write_label (label)
    @outfile << "label %s\n" % [label]
  end

  def write_goto (label)
    @outfile << "goto %s\n" % [label]
  end

  def write_if (label)
    @outfile << "if-goto %s\n" % [label]
  end

  def write_call (name, n_args)
    @outfile << "call %s %s\n" % [name, n_args]
  end

  def write_function (name, n_locals)
    @outfile << "function %s %s\n" % [name, n_locals]
  end

  def write_return
    @outfile << "return\n"
  end

  def close
    @outfile.close
  end
end
