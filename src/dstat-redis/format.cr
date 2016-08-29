module Dstat::Redis::Format
  abstract def format(keys : Array(String), vals : Array(Value)) : String
end
