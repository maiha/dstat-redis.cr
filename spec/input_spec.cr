require "./spec_helper"

private def type_cast(v)
  Dstat::Redis::Input.type_cast(v)
end

describe Dstat::Redis::Input do
  describe ".type_cast" do
    it "string" do
      type_cast("").should eq("")
      type_cast("1X23").should eq("1X23")
    end

    it "numeric" do
      type_cast("123").should eq(123)
    end

    it "numeric with unit" do
      type_cast("123B").should eq(123)
      type_cast("123K").should eq(123_000)
      type_cast("123M").should eq(123_000_000)
      type_cast("123G").should eq(123_000__000_000)
    end

    it "float" do
      type_cast("0.25").should eq(0.25)
    end

    it "float with unit" do
      type_cast("18.6B").should eq(18.6)
      type_cast("18.6K").should eq(18_600)
      type_cast("18.6M").should eq(18_600_000)
      type_cast("18.6G").should eq(18_600_000_000)
    end
  end
end
