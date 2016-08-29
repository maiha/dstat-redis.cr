class Dstat::Redis::Output::Redis
  include Output

  alias Connection = ::Redis | ::Redis::Cluster::Client
  
  def initialize(@redis : Connection, @commands : Array(String), @verbose : Bool = false)
  end

  def output(map : Mapping, format : Format)
    found = map.keys.to_set
    @commands.each do |cmd|
      args = cmd.split(/\s+/).map{|c| format.format(c, map)}
      STDOUT.puts "debug: #{args.inspect}" if @verbose
      @redis.command(args)
    end
  end
end
