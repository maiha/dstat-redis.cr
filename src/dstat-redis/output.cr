module Dstat::Redis::Output
  abstract def output(map : Mapping) : Nil
end
