module Twostroke::AST
  class Base
    {% if false %}
    abstract def get_val
    {% else %}
    def get_val(var2val)
      nil
    end
    {% end %}
  end

  class Twostroke::AST::ExpressionStatement
    def get_val(var2val)
      @expr.get_val(var2val)
    end
  end

  class Twostroke::AST::Call
    def get_val(var2val)
      Strazh::Value.new
    end
  end

  class Twostroke::AST::Variable
    def get_val(var2val)
      var2val[ @name.to_s ]? || raise Exception.new "Undefinded variable #{@name} line #{@line}"
    end
  end

  class Twostroke::AST::Assignment
    def get_val(var2val)
      v = @right.get_val(var2val)
      if !v.nil?
        var2val[ @left.name ] = v
      else
        raise Exception.new "Corrupted AST"
      end
    end
  end
end
