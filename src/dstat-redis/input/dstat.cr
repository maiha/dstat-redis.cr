class Dstat::Redis::Input::Dstat
  include Input

  @args : Array(String)

  delegate type_cast, to: Input
  
  def initialize(@prog : String, option)
    args = option.split(/\s+/)
    # add parameters for input that we want
    @args = args + ["-T", "--noheaders", "--nocolor", "--noupdate"]
  end

  def input : Nil
    # counter to skip leading headers
    line_count = 0
    headers = [] of String
    
    Process.run(@prog, @args) do |dstat|
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
          headers = cols
        else   # stats
          vals = cols.map{|v| type_cast(v)}
          hash = headers.zip(vals).to_h # TODO: perfomance tuning
          yield(hash)
        end
      }
    end
    nil
  end
end
