module Strazh
  class Value
    getter :corrupted

    def initialize(@bases_on = [] of Value)
      @corrupted = false
      @corrupted = @bases_on.reduce(false) { |acc, i| acc || self.check i }
    end

    def check(i : Value)
      false
    end
  end

  class Calable < Value
    def initialize(@return : Proc(Array(Value), Value), @bases_on = [] of Value)
      super(@bases_on)
    end

    def call(bases_on = [] of Value)
      @return.call bases_on
    end
  end

  class RawData < Value
  end

  class DbConnect < Value
    def check(i : Value)
      if i.is_a? Union
        i.@bases_on.each { |j| return true if j.is_a? RawData }
        false
      else
        i.is_a? RawData
      end
    end
  end

  class Union < Value
  end

  class Undef < Value
  end
end
