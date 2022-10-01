module Colors
  class HSV
    # Hue: 0-360^
    # Sat: 0-100%
    # Val: 0-100%
    # Alp: 0-255
    include Colors
    attr_accessor :h, :s, :v, :a
    def initialize(hsv=[18, 55.1, 61.2], a=255)
      @h, @s, @v = hsv
      @a = a
    end

    def fade(amount=0.85, fade_alpha=false)
      super(to_rgb, amount, fade_alpha).to_hsv
    end

    def saturate(amount=1.2)
      super(self, amount)
    end

    def to_rgb
      v, s = [@v, @s].map { |c| c / 100 }
      c = v * s
      x = c * (1 - (@h / 60.0 % 2 - 1).abs)
      m = v - c
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
      [@h, @s, @v, @a]
    end

    def to_h
      { h: @h, s: @s, v: @v, a: @a }
    end
  
    def map; to_a.map end
    def to_s; to_a.to_s end
    def serialize; to_s end
    def inspect; to_s end
  end
end