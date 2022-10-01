module Colors
  def saturate(color, amount=1.2)
    # Only saturate colors with a saturation
    raise 'InvalidColor' unless [HSL, HSV].include?(color.class)
    raise "InvalidFadeAmount" if !amount.is_a?(Numeric)

    if color.is_a?(HSL)
      h, s, l, a = color.to_a
      s *= amount
      HSL.new([h, s.round(2), l], a)
    else
      h, s, v, a = color.to_a
      s *= amount
      HSV.new([h, s.round(2), v], a)
    end
  end

  def darken(color, amount=0.95)
    # Only darken colors with a light or value
    raise 'InvalidColor' unless [HSL, HSV].include?(color.class)
    raise "InvalidFadeAmount" if !amount.is_a?(Numeric)

    if color.is_a?(HSL)
      h, s, l, a = color.to_a
      l *= amount
      HSL.new([h, s.round(2), l], a)
    else
      h, s, v, a = color.to_a
      v *= amount
      HSV.new([h, s.round(2), v], a)
    end
  end

  def lighten(color, amount=1.05)
    # Only lighten colors with a light or value
    raise 'InvalidColor' unless [HSL, HSV].include?(color.class)
    raise "InvalidFadeAmount" if !amount.is_a?(Numeric)

    if color.is_a?(HSL)
      h, s, l, a = color.to_a
      l *= amount
      HSL.new([h, s.round(2), l], a)
    else
      h, s, v, a = color.to_a
      v *= amount
      HSV.new([h, s.round(2), v], a)
    end
  end

  def fade(color, amount=0.85, fade_alpha=false)
    raise "InvalidColor" unless fadeable_color?(color)
    raise "InvalidFadeAmount" if !amount.is_a?(Numeric)

    # Ensure 'color' is an array
    faded = nil
    values = (color.class == Hash ? color.keys : color.to_a)
    if fade_alpha.is_a?(Numeric)
      faded = values.map { |c| c * amount }.push(values[3] * fade_alpha)
    else
      faded = values[0..2].map { |c| (c * amount).floor }.push(values[3])
    end
    RGB.new(faded[0..2], faded[-1])
  end

  def fadeable_color?(color)
    [RGB, Array, Hash].include?(color.class)
  end
  
  def map; to_a.map end
  def to_s; to_a.to_s end
  def serialize; to_s end
  def inspect; to_s end
end

def dec_to_hex decimal
  return decimal.to_s if decimal < 10
  case decimal
  when 10 then 'A'
  when 11 then 'B'
  when 12 then 'C'
  when 13 then 'D'
  when 14 then 'E'
  when 15 then 'F'
  end
end

def hex_to_dec hex
  # String char is an integer
  return hex.to_i if hex.to_s.ord.between?(48, 57)
  return case hex.upcase
  when 'A' then 10
  when 'B' then 11
  when 'C' then 12
  when 'D' then 13
  when 'E' then 14
  when 'F' then 15
  end
end

Color = Colors::RGB
ColorHSV = Colors::HSV
ColorHSL = Colors::HSL
ColorHex = Colors::Hex