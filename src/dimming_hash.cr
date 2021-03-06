module Strazh
  {% if true %}
    class DimmingHash(K, V) < Hash(K, V)
      property :parrent, :return, :corrupted

      def initialize(@parrent : Hash(K, V)? = nil)
        @return = [] of V
        @corrupted = [] of V
        super()
      end

      def [](key)
        if v = fetch(key, nil)
          v
        elsif p = @parrent
          p[key]
        else
          raise IndexError.new
        end
      end

      def []?(key)
        p = @parrent
        fetch(key, p ? p[key]? : nil)
      end

      def wrap
        hs = DimmingHash(K, V).new
        hs.corrupted = corrupted
        hs.parrent = self
        hs.return = @return
        hs
      end

      def wrap_return
        hs = DimmingHash(K, V).new
        hs.corrupted = corrupted
        hs.parrent = self
        hs
      end
    end
  {% else %}
    # Stub for checking overridden methods 
    class DimmingHash(K, V)
      def []=(key, value)
      end

      def []?(key)
      end

      def [](key)
        raise Exception.new
      end

      def wrap
        self
      end

      def parrent
        raise Exception.new
      end
    end
  {% end %}
end
