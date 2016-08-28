module Dstat::Redis::Output
  abstract def output(payload : String) : Nil
end
