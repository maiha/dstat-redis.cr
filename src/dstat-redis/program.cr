class Dstat::Redis::Program
  alias Connection = ::Redis | ::Redis::Cluster::Client

  @formatter : Proc(Array(String), String)
  @processor : Proc(String, Nil)

  def initialize(@config : TOML::Config, @redis : Connection)
    @verbose   = @config.bool("verbose").as(Bool)
    redis_cmds = @config.strs("redis/cmds")
    @formatter = ->(args : Array(String)) { "{}" }
    @processor = ->(json : String) {
      redis_cmds.each do |cmd|
        cmd  = cmd.gsub(/__json__/, json)
        args = cmd.split(/\s+/)
        STDOUT.puts "debug: #{args.inspect}" if @verbose
        @redis.command(args)
      end
      nil
    }
  end

  def run
    prog = @config.str("dstat/prog")
    args = @config.str("dstat/args").split(/\s+/)

    # add parameters for output that we want
    args = args + ["-T", "--noheaders", "--nocolor", "--noupdate"]

    # counter to skip leading headers
    line_count = 0
    
    Process.run(prog, args) do |dstat|
      loop {
        line = dstat.output.gets
        next if line.nil?
        line_count += 1
        line = line.as(String).chomp
        cols = line.strip.split(/[\s+\|]+/)

        # [line:1] "\e[7l--epoch--- ------memory-usage----- -dsk/total-\n"
        # [line:2] "  epoch   | used  buff  cach  free| read  writ\n"
        # [line:3] "1472196576|1192M  132M 7024M 2969M| 728B   35k\n"
        case line_count
        when 1 # skip
        when 2 # header
          # ["epoch", "used", "buff", "cach", "free", "read", "writ"]
          @formatter = ->(args : Array(String)) {
            fmt = "{" + cols.map{|i| %("#{i}":"%s") }.join(",") + "}"
            fmt % args
          }
        else   # stats
          @processor.call(@formatter.call(cols))
        end
      }
    end
  end
end

