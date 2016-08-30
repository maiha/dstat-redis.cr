class Dstat::Redis::Program
  def initialize(@input : Input, @format : Format, @output : Output)
  end

  def run
    @input.input do |tval|
      result = tval.map{|val| @output.output(val, @format)}
      report(result)
    end
  end

  # TODO
  private def report(result)
    case result
    when Success
    when Failure
    else
    end
  end
end
