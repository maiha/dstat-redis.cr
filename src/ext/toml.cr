require "toml"

class TOML::Config
  alias Type = Hash(String, TOML::Type)

  def self.parse_file(file)
    new(TOML.parse_file(file))
  end

  def initialize(toml : Type)
    @paths = Hash(String, TOML::Type).new
    build_path(toml, "")
  end

  ######################################################################
  ### Primary API
  
  def [](key)
    key = key.to_s
    @paths.fetch(key) { not_found(key) }
  end

  def []?(key)
    key = key.to_s
    @paths.fetch(key) { nil }
  end

  def []=(key, val : TOML::Type)
    hash = @paths
    keys = key.split("/")
    keys.each_with_index do |k, i|
      if i == keys.size - 1
        hash[k] = val
      else
        if ! hash.is_a?(Hash)
          raise "Not hash: TOML::Config[#{key}] = value"
        end
        hash = (hash[k] ||= Type.new).as(Hash)
      end
    end
    val
  end

  ######################################################################
  ### Syntax Sugar
  
  def str(key)
    self[key].as(String)
  end

  def str?(key)
    self[key]?.as(String?)
  end

  def strs(key)
    self[key].as(Array).map(&.to_s).as(Array(String))
  end

  def int64(key)
    self[key].as(Int64)
  end

  def int64?(key)
    self[key]?.try(&.as(Int64))
  end

  def int(key)
    int64(key).to_i32.as(Int32)
  end

  def int?(key)
    int64?(key).try(&.to_i32.as(Int32))
  end

  def ints(key)
    self[key].as(Array).map(&.to_i32).as(Array(Int32))
  end

  def bool(key)
    if self[key]?
      self[key].as(Bool)
    else
      false
    end
  end

  ######################################################################
  ### Internal Functions
  
  protected def not_found(key)
    raise "toml[%s] is not found" % key
  end

  private def build_path(toml, path)
    case toml
    when Hash
      toml.each do |(key, val)|
        build_path(val, path.empty? ? key : "#{path}/#{key}")
      end
    else
      @paths[path] = toml
    end
  end
end
