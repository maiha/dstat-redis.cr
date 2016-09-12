class Dstat::Redis::Input::Dstat
  include Input

  @args : Array(String)

  delegate type_cast, to: Input
  
  def initialize(@prog : String, option)
    args = option.split(/\s+/)
    # add parameters for input that we want
    @args = args + ["-T", "--noheaders", "--nocolor", "--noupdate"]

    # counter to skip leading headers
    @line_count = 0_i64
    @headers = [] of String
  end

  class Skip < Exception
  end
  
  def input : Nil
    Process.run(@prog, @args) do |dstat|
      loop {
        begin
          value = process(dstat.output)
          yield Try(Mapping).try { value }
        rescue Skip
          next
        rescue err
          yield Failure(Mapping).new(err)
        end
      }
    end
    nil
  end

  private def process(output)
    line = output.gets
    if line.nil?
      sleep 3                   # avoid infinite loop
      raise "line is nil (#{@line_count})"
    end

    @line_count += 1
    line = line.as(String).chomp
    cols = line.strip.split(/[\s+\|]+/)

    # [line:1] "\e[7l--epoch--- ------memory-usage----- -dsk/total-\n"
    # [line:2] "  epoch   | used  buff  cach  free| read  writ\n"
    # [line:3] "1472196576|1192M  132M 7024M 2969M| 728B   35k\n"
    case @line_count
    when 1 # skip
      raise Skip.new("#{@line_count}")

    when 2 # header
      # ["epoch", "used", "buff", "cach", "free", "read", "writ"]
      @headers = cols
      raise Skip.new("headers found (#{@line_count})")

    else   # stats
      vals = cols.map{|v| type_cast(v)}
      hash = @headers.zip(vals).to_h # TODO: perfomance tuning
      return hash
    end
  end
end
