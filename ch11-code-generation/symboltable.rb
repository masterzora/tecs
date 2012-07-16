class SymbolTable
  def initialize 
    @class_vars = {}
    @sub_vars = {}
    @indices = {
      :static => 0,
      :field  => 0,
      :arg    => 0,
      :var    => 0,
    }
  end

  def start_subroutine
    @sub_vars = {}
    @indices[:arg] = 0
    @indices[:var] = 0
  end

  def define (name, type, kind)
    if kind == :arg or kind == :var
      @sub_vars[name] = [type, kind, @indices[kind]]
    else
      @class_vars[name] = [type, kind, @indices[kind]]
    end
    @indices[kind] += 1
  end

  def var_count (kind)
    @indices[kind]
  end

  def kind_of (name)
    if @sub_vars.has_key?(name)
      @sub_vars[name][1]
    elsif @class_vars.has_key?(name)
      @class_vars[name][1]
    else
      :none
    end
  end

  def type_of (name)
    if @sub_vars.has_key?(name)
      @sub_vars[name][0]
    elsif @class_vars.has_key?(name)
      @class_vars[name][0]
    end
  end

  def index_of (name)
    if @sub_vars.has_key?(name)
      @sub_vars[name][2]
    elsif @class_vars.has_key?(name)
      @class_vars[name][2]
    end
  end
end
