module Dstat::Redis::Format
  abstract def format(keys : Array(String), vals : Array(String)) : String
end
