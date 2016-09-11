class Dstat::Redis::Output::Redis
  include Output

  def initialize(@redis : ::Redis::Client, @commands : Array(String), @format : Format)
  end

  def output(map : Mapping)
    Try(String).try {
      found = map.keys.to_set
      @commands.map do |cmd|
        args = cmd.split(/\s+/).map{|c| @format.format(c, map)}
        res = @redis.command(args)
        "[%s] %s" % [res, args.inspect]
      end.join("\n")
    }
  end
end
