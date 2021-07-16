module Strazh
  class TypeChecker
    @stsm : Array(Twostroke::AST::Base)

    def initialize(code : String, @var2val = {} of String => Value, @debug = false)
      puts code if @debug

      lexer = Twostroke::Lexer.new code
      parser = Twostroke::Parser.new lexer
      parser.parse
      @stsm = parser.statements
    end

    def check
      @stsm.each do |i|
        i.get_val(@var2val)
        puts(Strazh.pretty(i), "", Strazh.pretty(@var2val), "---") if @debug
      end
      @var2val
    end
  end
end
