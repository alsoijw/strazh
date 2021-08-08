require "./spec_helper"
require "./shading_hash"

def var2val
  Strazh::DimmingHash{
    "raw_data" => Strazh::Calable.new(->(_a : Array(Strazh::Value)) { Strazh::RawData.new.as Strazh::Value }).as Strazh::Value,
    "safe_data" => Strazh::Calable.new(->(_a : Array(Strazh::Value)) { Strazh::Value.new }),
    "db_query" => Strazh::Calable.new(->(a : Array(Strazh::Value)) { Strazh::DbConnect.new(a).as Strazh::Value })
  }
end

describe Strazh do
  it "assigned 1" do
    h = Strazh::TypeChecker.new(<<-CODE, Strazh::DimmingHash{ "b" => Strazh::Value.new }).check
    a = b
    CODE
    h["a"].should eq(h["b"])
  end

  it "assigned 2" do
    a = b = Strazh::Value.new
    h = Strazh::TypeChecker.new(<<-CODE, Strazh::DimmingHash{ "a" => a, "b" => b, "c" => Strazh::Value.new }).check
    a = c
    CODE
    h["a"].should_not eq(h["b"])
  end

  it "raw values 1" do
    h = Strazh::TypeChecker.new(<<-CODE, var2val).check
    a = raw_data()
    CODE
    h["a"].class.should eq(Strazh::RawData)
  end

  it "raw value 2" do
    tc = Strazh::TypeChecker.new("a = db_query(raw_data())", var2val
    )
    h = tc.check
    h["a"].class.should eq(Strazh::DbConnect)
    h["a"].corrupted.should eq(true)

    tc.corrupted.should eq([ h["a"] ])
  end
end
