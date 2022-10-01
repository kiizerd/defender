module Colors
  class Hex
    include Colors
    def initialize(string="#9C6046", alpha=255)
      @string = string
      @digits = string.chars[1..-1]
      @alpha = alpha
    end

    def to_rgb
      decimal_digits = @digits.map { |hex_digit| hex_to_dec(hex_digit).to_i }
      r1, r2, g1, g2, b1, b2 = decimal_digits
      r = r1 * 16 + r2
      g = g1 * 16 + g2
      b = b1 * 16 + b2
      RGB.new([r, g, b], @alpha)
    end
    
    def to_a; @digits end
    def map; to_a.map end
    def to_s; @string end
  end
end
