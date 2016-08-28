class Dstat::Redis::Output::Redis
  include Output

  alias Connection = ::Redis | ::Redis::Cluster::Client
  
  def initialize(@redis : Connection, @commands : Array(String), @verbose : Bool = false)
  end

  def output(payload : String)
    @commands.each do |cmd|
      cmd  = cmd.gsub(/__json__/, payload)
      args = cmd.split(/\s+/)
      STDOUT.puts "debug: #{args.inspect}" if @verbose
      @redis.command(args)
    end
  end
end
