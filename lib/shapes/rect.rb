module Shapes
  class Rect
    attr_sprite
    def initialize pos, size
      @x, @y = pos
      @w, @h = size
    end
    
    def sides
      %i[top left right bottom].map do |s|
        get_side(s)
      end.to_h
    end

    def get_side side_symbol
      side_rect = {}
      case side_symbol
      when :top    then side_rect = top
      when :left   then side_rect = left
      when :right  then side_rect = right
      when :bottom then side_rect = bottom
      end
      [side_symbol, side_rect]
    end

    # These all need to be corrected
    def top
      { x: @x - 1, y: @y + @h - 1, w: @w + 2, h: 3 }
    end

    def left
      { x: @x - 1, y: @y - 1, w: 3, h: @h + 2 }
    end

    def right
      { x: @x + @w - 1, y: @y - 1, w: 3, h: @h + 2 }
    end

    def bottom
      { x: @x - 1, y: @y - 1, w: @w + 2, h: 3 }
    end
  end
end
