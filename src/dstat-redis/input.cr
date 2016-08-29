module Dstat::Redis::Input
  def self.type_cast(v)
    case v
    when /^(\d+)B?$/i then $1.to_i
    when /^(\d+)K$/i  then $1.to_i * 1000
    when /^(\d+)M$/i  then $1.to_i64 * 1000 * 1000
    when /^(\d+)G$/i  then $1.to_i64 * 1000 * 1000 * 1000
    when /^(\d+)\.(\d+)B?$/i then v.to_f
    when /^(\d+)\.(\d+)K$/i  then (v.to_f * 1000).to_i
    when /^(\d+)\.(\d+)M$/i  then (v.to_f * 1000 * 1000).to_i64
    when /^(\d+)\.(\d+)G$/i  then (v.to_f * 1000 * 1000 * 1000).to_i64
    else v
    end
  end

#  abstract def input : Nil
end
