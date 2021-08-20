module Strazh
  def var2val
    DimmingHash{
      "raw_data" => Calable.new(->(_a : Array(Value), v2v : DimmingHash(String, Value)) { RawData.new.as Value }).as Value,
      "safe_data" => Calable.new(->(_a : Array(Value), v2v : DimmingHash(String, Value)) { Value.new }),
      "db_query" => Calable.new(->(a : Array(Value), v2v : DimmingHash(String, Value)) { DbConnect.new(a).as Value })
    }
  end

  def if_test
    DimmingHash{
      "_" => Calable.new(->(_a : Array(Value), v2v : DimmingHash(String, Value)) { Numbered.new.as Value }).as Value,
      "b" => Value.new
    }
  end

  class Value
    property :bases_on
  end

  class Numbered < Value
    @@all = 0
    property :id

    def initialize(@bases_on = [] of Value)
      @corrupted = false
      @id = 0
      @id = @@all
      @@all += 1
    end

    def self.reset
      @@all = 0
    end
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

    it "if 0" do
      code1 = <<-CODE
      if(raw_data()) {
        a = raw_data()
      } else {
        a = safe_data()
      }
      a = db_query(a)
      CODE

      code2 = <<-CODE
      if(raw_data()) {
        a = safe_data()
      } else {
        a = raw_data()
      }
      a = db_query(a)
      CODE

      tc1 = Strazh::TypeChecker.new(code1, var2val)
      h1 = tc1.check

      tc2 = Strazh::TypeChecker.new(code2, var2val)
      h2 = tc2.check

      h1["a"].corrupted.should eq(h2["a"].corrupted)
      tc1.corrupted.should eq([ h1["a"] ])
      tc2.corrupted.should eq([ h2["a"] ])
    end

    it "if 1" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      a = _()
      if(b)
        a = _()
      CODE
      h["a"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 1, 0 ])
    end

    it "if 2" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      a = _()
      if(a = _())
        _()
      CODE
      h["a"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 1 ])
    end

    it "if 3" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      a = _()
      if(a = _())
        a = _()
      CODE
      h["a"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 2, 1 ])
    end

    it "if 4" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      a = _()
      if(a = _())
        a = _()
      else
        a = _()
      CODE
      h["a"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 2, 3 ])
    end

    it "if 5" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      a = _()
      if(a = _())
        a = _()
      else if(_())
        a = _()
      CODE
      h["a"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 2, 4, 1 ])
    end

    it "if 6" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      a = _()
      if(a = _())
        a = _()
      else if(a = _())
        a = _()
      else
        a = _();
      CODE
      h["a"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 2, 4, 5 ])
    end

    it "if 4" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      a = _()
      if(_()) {
        if(a = _()) {
          a = _()
        } else {
          a = _()
        }
      } else {
        _()
      }
      CODE
      h["a"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 3, 4, 0 ])
    end

    it "function 1" do
      Numbered.reset
      tc = TypeChecker.new(<<-CODE, var2val)
      b = a(raw_data())

      function a(b) {
        return db_query(b);
      }
      CODE
      h = tc.check
      h["b"].bases_on.should eq(tc.corrupted)
    end

    it "function 2" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      c = a()

      function a() {
        if(b) {
          return _();
        } else {
          return _();
        }
      }
      CODE
      h["c"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 0, 1 ])
    end

    it "function 3" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      b = a()

      function a() {
        function c() {
          return _();
        }
        return c();
      }
      CODE
      h["b"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 0 ])
    end

    it "function 4" do
      Numbered.reset
      h = TypeChecker.new(<<-CODE, if_test).check
      b = a()

      function a() {
        function c() {
          return _();
        }
        c();
        return _();
      }
      CODE
      h["b"].bases_on.map { |i| i.as(Numbered).id }.uniq.should eq([ 1 ])
    end
  end
end
