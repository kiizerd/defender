class Player < Arbor::Entity
  include Component::Position
  include Component::Size
  include Component::Motion
  # prepend Component::Sprite
  attr_sprite

  def initialize(opts = {})
    super(opts)
  end
end
#     # attr_reader :shape
#     # attr_sprite

#     # def initialize x, y, w, h, rgba
#     #   @x = x
#     #   @y = y
#     #   @w = w
#     #   @h = h
#     #   @rgba = rgba

#     #   @dx = 0
#     #   @dy = 0
#     #   @speed = 5
#     # end

#     # def tick(args)
#     #   calc(args.state)
#     #   handle_inputs(args.inputs)
#     # end

#     # def calc(state)
#     #   # resolve forces
#     #   @x += (@dx *= 0.9)
#     #   @y += (@dy *= 0.9)
#     # end
    
#     # def handle_inputs(inputs)
#     #   dv = inputs.directional_vector
#     #   return if !dv
      
#     #   @dx = (dv.x * @speed)
#     #   @dy = (dv.y * @speed)
#     # end
    
#     # def rect
#     #   { x: @x, y: @y, w: @w, h: @h }
#     # end

#     # def center
#     #   [ @x + @w.half, @y + @h.half ]
#     # end

#     # def next_rect
#     #   rect.merge(x: @x + @dx, y: @y + @dy, w: @w + 2, h:  @h + 2)
#     # end