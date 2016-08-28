module Dstat::Redis::Input
  alias Type = String | Int32 | Int64 | Float64

  def self.type_cast(v)
    case v
    when /^(\d+)B?$/i then $1.to_i
    when /^(\d+)K$/i  then $1.to_i * 1000
    when /^(\d+)M$/i  then $1.to_i * 1000 * 1000
    when /^(\d+)G$/i  then $1.to_i64 * 1000 * 1000 * 1000
    when /^(\d+)\.(\d+)$/ then v.to_f
    else v
    end
  end

#  abstract def input : Nil
end
