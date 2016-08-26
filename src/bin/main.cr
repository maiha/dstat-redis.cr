require "../dstat-redis"

class Main
  include Opts

  VERSION = "0.1.0"
  PROGRAM = "dstat-redis"
  ARGS    = "config.toml"

  option verbose : Bool, "-v", "Verbose output", false
  option version : Bool, "--version", "Print the version and exit", false
  option help    : Bool, "--help"   , "Output this help and exit" , false

  def run
    conf = TOML::Config.parse_file(args.shift { die "config not found!" })
    conf["verbose"] = verbose

    redis = connect(conf)
    Dstat::Redis::Program.new(conf, redis).run
  end

  private def connect(conf)
    host = conf.str("redis/host")
    port = conf.int("redis/port")
    pass = conf.str?("redis/pass")

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
