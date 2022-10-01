module Colors
  class HSL
    # Hue: 0-360^
    # Sat: 0-100%
    # Lht: 0-100%
    # Alp: 0-255
    include Colors
    attr_accessor :h, :s, :l, :a
    def initialize(hsl=[18, 38.1, 44.3], a=255)
      @h, @s, @l = hsl
      @a = a
    end

    def fade(amount=0.85, fade_alpha=false)
      super(to_rgb, amount, fade_alpha).to_hsl
    end

    def saturate(amount=1.2)
      super(self, amount)
    end

    def darken(amount=0.95)
      super(self, amount)
    end

    def lighten(amount=1.05)
      super(self, amount)
    end

    def to_rgb
      l, s = [@l, @s].map { |c| c / 100 }
      c = (1 - (2 * l - 1).abs) * s
      x = c * (1 - (h / 60.0 % 2 - 1).abs)
      m = l - c / 2
      r, g, b = case h
      when 0...60 then [c, x, 0]
      when 60...120 then [x, c, 0]
      when 120...180 then [0, c, x]
      when 180...240 then [0, x, c]
      when 240...300 then [x, 0, c]
      when 300...360 then [c, 0, x]
      end
      rgb = [r, g, b].map { |c| ((c + m) * 255).round }
      RGB.new(rgb, @a)
    end

    def to_a
      [@h, @s, @l, @a]
    end

    def to_h
      { h: @h, s: @s, l: @l, a: @a }
    end
  end
end
