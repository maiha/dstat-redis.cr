module Dstat::Redis::Format
  abstract def format(tmpl : String, map : Mapping) : String
end
