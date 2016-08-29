require "../dstat-redis"

class Main
  include Opts
  include Dstat::Redis

  VERSION = "0.2.0"
  PROGRAM = "dstat-redis"
  ARGS    = "config.toml"

  option verbose : Bool, "-v", "Verbose output", false
  option version : Bool, "--version", "Print the version and exit", false
  option help    : Bool, "--help"   , "Output this help and exit" , false


  @config : TOML::Config?
  getter! config
  delegate str, str?, strs, int, bool, to: config
  
  def run
    @config = TOML::Config.parse_file(args.shift { die "config not found!" })
    config["verbose"] = verbose

    Program.new(input, format, output).run
  end

  private def input
    prog = str("dstat/prog")
    args = str("dstat/args")
    Input::Dstat.new(prog, args)
  end

  private def format
    Dstat::Redis::Format::Json.new
  end

  private def output
    redis = redis_connect(str("redis/host"), int("redis/port"), str?("redis/pass"))
    Output::Redis.new(redis, strs("redis/cmds"), verbose: bool("verbose"))
  end
  
  private def redis_connect(host, port, pass)
    STDOUT.print "Connecting #{host}:#{port} ... "
    redis = ::Redis.new(host, port, password: pass)
    STDOUT.puts "OK"

    begin
      redis.command(["cluster", "nodes"])
    rescue e : Redis::Error
      if /This instance has cluster support disabled/ === e.message
        return redis
      else
        # Just raise it because it would be a connection problem like AUTH error.
        raise e
      end
    end

    return ::Redis::Cluster.new("#{host}:#{port}", password: pass)
  end
end

Main.run
