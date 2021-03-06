module Strazh
  class TypeChecker
    def corrupted
      @var2val.corrupted
    end

    @stsm : Array(Twostroke::AST::Base)

    def initialize(code : String, @var2val : DimmingHash(String, Value) = DimmingHash{} of String => Value, @debug = false)
      puts code if @debug

      lexer = Twostroke::Lexer.new code
      parser = Twostroke::Parser.new lexer
      parser.parse
      @stsm = parser.statements

      puts Strazh.pretty(@stsm) if @debug
    end

    def def_func(stsm)
      stsm.each do |i|
        if i.is_a? Twostroke::AST::Function
          @var2val[ i.name ] = Calable.new(@var2val, ->(a : Array(Value), v2v : DimmingHash(String, Value)) {
            i.@arguments.map_with_index { |v, k| v2v[v.to_s] = a[k] }
            check_stsm(i.statements, v2v)
            Union.new(v2v, v2v.return).as Value })
        end
      end
    end

    def check
      check_stsm(@stsm, @var2val)
    end

    def check_stsm(stsm, v2v)
      def_func stsm
      stsm.each do |i|
        v = i.get_val(v2v)
        puts(
          Strazh.pretty(i),
          "",
          Strazh.pretty(v2v),
          "",
          Strazh.pretty(@var2val.corrupted),
          "---",
        ) if @debug
      end
      v2v
    end
  end
end
