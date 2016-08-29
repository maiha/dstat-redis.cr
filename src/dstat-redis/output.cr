module Dstat::Redis::Output
  abstract def output(map : Mapping, format : Format) : Nil
end
