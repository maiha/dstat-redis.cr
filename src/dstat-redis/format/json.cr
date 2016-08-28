require "json"

class Dstat::Redis::Format::Json
  include Format

  @format : String?
  
  def format(keys : Array(String), vals : Array(Input::Type))
    @format ||= compile(keys)
    @format.not_nil! % vals.map(&.to_json)
  end

  private def compile(keys : Array(String))
    @format = "{" + keys.map{|i| %("#{i}":%s) }.join(",") + "}"
  end
end
