require "colorize"

class Dstat::Redis::Program
  def initialize(@input : Input, @output : Output, @report : Periodical::Reporter? = nil, @verbose : Bool = false)
  end

  def run
    @input.input do |tval|
      result = tval.map{|val| @output.output(val)}
      report(result)
    end
  end

  private def report(result)
    case result
    when Success then @report.try(&.debug(result.value, time: true)) if @verbose
    when Failure then @report.try(&.error(result.value, time: true))
    end
    @report.try(&.succ { result.get })
  end
end
