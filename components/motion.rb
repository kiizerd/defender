module Component
  module Motion
    def move(delta_x = 0.0, delta_y = 0.0)
      @x += delta_x
      @y += delta_y
    end
  end
end
