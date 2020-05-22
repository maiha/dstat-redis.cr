require "json"

class Dstat::Redis::Format::Json
  include Format

  def initialize
    @host = System.hostname
  end
  
  def format(tmpl : String, map : Mapping) : String
    tmpl.gsub(/__(.*?)__/) {
      if $1 == "json"
        map.to_json
      elsif $1 == "host"
        @host
      elsif map[$1]?
        map[$1]
      elsif $1.starts_with?("%")
        Pretty.epoch(map["epoch"].to_i).to_local.to_s($1)
      else
        "__#{$1}__"
      end
    }
  end
end
