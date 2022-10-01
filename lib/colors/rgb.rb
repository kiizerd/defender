module Colors
  class RGB
    include Colors
    attr_accessor :r, :g, :b, :a
    def initialize(rgb=[156, 96, 70], a=255)
      @r, @g, @b = rgb
      @rgb = [@r, @g, @b]
      @a = a
    end

    def fade(amount=0.85, fade_alpha=false)
      super(self, amount, fade_alpha)
    end

    def to_a
      [@r, @g, @b, @a]
    end

    def to_h
      { r: @r, g: @g, b: @b, a: @a }
    end

    def to_hex
      values = @rgb.map do |c|
        hex1 = c / 16
        hex2 = (hex1 % 1) * 16

        "#{dec_to_hex(hex1.floor)}#{dec_to_hex(hex2.floor)}"
      end.join
      "##{values}"
    end

    def to_hsv
      h, s, v = nil
      r, g, b = to_a[0..2].map { |c| c / 255.0 }
      mx = [r, g, b].max
      mn = [r, g, b].min
      df = mx - mn
      if mx == mn
        h = 0
      elsif mx == r
        h = (60 * ((g-b)/df) + 360) % 360
      elsif mx == g
        h = (60 * ((b-r)/df) + 120) % 360
      elsif mx == b
        h = (60 * ((r-g)/df) + 240) % 360
      end
      s = mx == 0 ? 0 : (df/mx)
      v = mx
      hsv = [h.round, s.round(3)*100, v.round(3)*100]
      HSV.new(hsv, @a)
    end

    def to_hsl
      h, s, l = nil
      r, g, b = to_a[0..2].map { |c| c / 255.0 }
      mx = [r, g, b].max
      mn = [r, g, b].min
      df = mx - mn
      if df == 0
        h = 0
      elsif mx == r
        h = (60 * ((g-b)/df) + 360) % 360
      elsif mx == g
        h = (60 * ((b-r)/df) + 120) % 360
      elsif mx == b
        h = (60 * ((r-g)/df) + 240) % 360
      end
      l = (mx + mn) / 2
      s = df == 0 ? 0 : df / (1 - (2 * l - 1).abs)
      hsl = [h.round, s.round(3)*100, l.round(3)*100]
      HSL.new(hsl, @a)
    end
  end
end