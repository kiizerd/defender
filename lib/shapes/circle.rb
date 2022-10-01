module Shapes
  class Circle
    attr_reader :x, :y, :r, :points, :lines
    def initialize pos, radius
      @x, @y = pos
      @r = radius
      @points = generate_points(72)
      @lines = generate_lines
    end

    def generate_points(count=72, radius=@r)
      angles = count.times.map { |i| (i + 1) * (360 / count) }
      angles.map do |angle|
        radian = angle * Math::PI / 180
        x = radius * Math::cos(radian).round(6) + @x
        y = radius * Math::sin(radian).round(6) + @y
        [x.round, y.round]
      end
    end

    def generate_lines
      @points.map_with_index do |point, index|
        next_point = @points[index + 1 == @points.size ? 0 : index + 1]
        line = { x1: point.x, y1: point.y, x2: next_point.x, y2: next_point.y }
        line.merge(rgba: Color.new.to_a)
      end
    end

    def center_fill
      ((@x - @r)..@x).map do |x|
        ((@y - @r)..@y).map do |y|
          if ((x - @x)*(x - @x) + (y - @y) * (y - @y) < r*r)
            sym_x = @x - (x - @x)
            sym_y = @y - (y - @y)
            [[x, y - 1], [x, sym_y], [sym_x, y - 1], [sym_x, sym_y]].map do |pixel|
              pixel.push(2, 2, Color.new.to_a)
            end
          else
            nil
          end
        end.compact
      end.flatten(1)
    end
  end
end
