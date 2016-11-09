require "../dstat-redis"
require "opts"
require "toml-config"

class Main
  include Opts
  include Dstat::Redis

  VERSION = "0.4.2"
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
    Program.new(input, output, report, verbose: bool("verbose")).run
  end

  private def input
    Input::Dstat.new(str("dstat/prog"), str("dstat/args"))
  end

  private def output
    redis = Redis::Client.new(str("redis/host"), int("redis/port"), password: str?("redis/pass"))
    format = Dstat::Redis::Format::Json.new
    Output::Redis.new(redis, strs("redis/cmds"), format)
  end

  private def report
    Periodical::Reporter.new(interval: int("log/interval_sec").seconds, time_format: str("log/time_format"))
  end
end

Main.run
