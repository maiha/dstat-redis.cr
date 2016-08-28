class Dstat::Redis::Program
  def initialize(@input : Input, @format : Format, @output : Output)
  end

  def run
    @input.input do |keys, vals|
      payload = @format.format(keys, vals)
      @output.output(payload)
    end
  end
end

