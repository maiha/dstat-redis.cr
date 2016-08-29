class Dstat::Redis::Program
  def initialize(@input : Input, @format : Format, @output : Output)
  end

  def run
    @input.input do |val|
      @output.output(val, @format)
    end
  end
end

