require "./spec_helper"

describe Strazh do
  it "assigned 1" do
    h = Strazh::TypeChecker.new(<<-CODE, { "b" => Strazh::Value.new }).check
    a = b
    CODE
    h["a"].should eq(h["b"])
  end

  it "assigned 2" do
    a = b = Strazh::Value.new
    h = Strazh::TypeChecker.new(<<-CODE, { "a" => a, "b" => b, "c" => Strazh::Value.new }).check
    a = c
    CODE
    h["a"].should_not eq(h["b"])
  end
end
