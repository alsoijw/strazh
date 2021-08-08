module Strazh
  def var2val
    DimmingHash{
      "raw_data" => Calable.new(->(_a : Array(Value)) { RawData.new.as Value }).as Value,
      "safe_data" => Calable.new(->(_a : Array(Value)) { Value.new }),
      "db_query" => Calable.new(->(a : Array(Value)) { DbConnect.new(a).as Value })
    }
  end

  describe Strazh do
    it "assigned 1" do
      h = TypeChecker.new(<<-CODE, DimmingHash{ "b" => Value.new }).check
      a = b
      CODE
      h["a"].should eq(h["b"])
    end

    it "assigned 2" do
      a = b = Value.new
      h = TypeChecker.new(<<-CODE, DimmingHash{ "a" => a, "b" => b, "c" => Value.new }).check
      a = c
      CODE
      h["a"].should_not eq(h["b"])
    end

    it "raw values 1" do
      h = TypeChecker.new(<<-CODE, var2val).check
      a = raw_data()
      CODE
      h["a"].class.should eq(RawData)
    end

    it "raw value 2" do
      tc = TypeChecker.new("a = db_query(raw_data())", var2val
      )
      h = tc.check
      h["a"].class.should eq(DbConnect)
      h["a"].corrupted.should eq(true)

      tc.corrupted.should eq([ h["a"] ])
    end
  end
end
