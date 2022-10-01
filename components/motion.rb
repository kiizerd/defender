module Component
  module SimpleMotion
    def move(delta_x = 0.0, delta_y = 0.0)
      speed = @speed ? @speed : 1
      @x += delta_x * speed
      @y += delta_y * speed
    end
  end

  module ComplexMotion
    def move(delta_x = 0.0, delta_y = 0.0)
      @dx ||= 0
      @dy ||= 0

      speed = @motion_speed ? @motion_speed : 1
      @dx += delta_x * speed
      @dy += delta_y * speed
    end

    def tick_motion
      @dx ||= 0
      @dy ||= 0

      decay = @motion_decay ? @motion_decay : 0.9

      @x += (@dx *= decay)
      @y += (@dy *= decay)
    end
  end
end
