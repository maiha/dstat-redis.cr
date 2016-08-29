require "./spec_helper"

private def format(s, map = mapping)
  Dstat::Redis::Format::Json.new.format(s, map)
end

private def mapping
  {
    "epoch" => 1472464405,
    "free"  => 17500000000,
    "1m"    => 0.45,
    "tim"   => 0,
  }
end

describe Dstat::Redis::Format::Json do
  describe "#format" do
    it "non special strings" do
      format("foo").should eq("foo")
    end

    it "json" do
      format("json is __json__").should eq(%(json is {"epoch":1472464405,"free":17500000000,"1m":0.45,"tim":0}))
    end

    it "host" do
      format("__host__").should_not eq("__host__")
    end

    it "fields" do
      format("__epoch__: TIME_WAIT(__tim__)").should eq("1472464405: TIME_WAIT(0)")
    end

    it "strftime" do
      format("__%Y-%m-%d__").should match(/^\d{4}-\d{2}-\d{2}$/)
    end
  end
end
