module Strazh
  class Value
    getter :corrupted

    def initialize(bases_on = [] of Value)
      @bases_on = [] of Value
      bases_on.each do |i|
        if i.is_a? Strazh::Union
          i.@bases_on.each { |j| @bases_on << j }
        else
          @bases_on << i
        end
      end
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
      i.is_a? RawData
    end
  end

  class Union < Value
  end

  class Undef < Value
  end
end
