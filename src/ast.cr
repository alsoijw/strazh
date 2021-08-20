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

  class Call
    def args_whitout_nill
      args
    end

    def get_val(var2val)
      if t = var2val[ @callee.name.to_s ]?
        if t.is_a? Strazh::Calable
          t.call var2val.wrap_return, @arguments
            .reduce([] of Base) { |acc, i| i.nil? ? acc : acc.push(i) }
            .map(&.get_val(var2val))
            .reduce([] of Strazh::Value) { |acc, i| i.nil? ? acc : acc.push(i) }
        else
          raise Exception.new "#{@callee.name} is not a function line #{@line}"
        end
      else
        raise Exception.new "Undefinded function #{@callee.name} line #{@line}"
      end
    end
  end

  class If
    def get_val(var2val)
      t = var2val.wrap
      @condition.with { |i| i.get_val t }
      e = var2val.wrap
      t.each { |k, v| e[k] = v }
      @then.with { |i| i.get_val t }
      @else.with { |i| i.get_val e }
      (t.keys + e.keys).uniq.each { |k| var2val[k] = Strazh::Union.new [ t, e ].map { |v| v[k]?.or Strazh::Undef.new } }
    end
  end

  class Body
    def get_val(var2val)
      @statements.map { |i| i.get_val var2val if !i.nil? }
      nil
    end
  end

  class Return
    def get_val(var2val)
      r = @expression.with { |i| i.get_val var2val }.or Strazh::Undef.new
      var2val.return << r
      r
    end
  end
end
