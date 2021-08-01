module Strazh
  class TypeChecker
    getter :corrupted

    @stsm : Array(Twostroke::AST::Base)

    def initialize(code : String, @var2val = {} of String => Value, @debug = false)
      @corrupted = [] of Value
      puts code if @debug

      lexer = Twostroke::Lexer.new code
      parser = Twostroke::Parser.new lexer
      parser.parse
      @stsm = parser.statements
    end

    def check
      @stsm.each do |i|
        v = i.get_val(@var2val)
        @corrupted.push v if !v.nil? && v.corrupted
        puts(
          Strazh.pretty(i),
          "",
          Strazh.pretty(@var2val),
          "",
          Strazh.pretty(@corrupted),
          "---",
        ) if @debug
      end
      @var2val
    end
  end
end
