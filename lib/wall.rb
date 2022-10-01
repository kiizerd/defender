class Wall
  attr_reader :size, :pos, :shape, :segments
  attr_sprite

  def initialize origin, size, dir
    @size      = size
    @dir       = dir
    @x, @y = [origin.x * origin.w, origin.y * origin.h]
    @w, @h = calc_wall_dimensions(origin, size, dir)

    @rgba = $state.defaults.wall_color || CORAL
    @r, @g, @b, @a = @rgba

    @segments = generate_wall_segments(origin, size, dir)
  end

  def draw
    @segments.map { |s| s.merge(rgba: @rgba) }
  end

  def calc_wall_dimensions origin, size, dir
    w = 0
    h = 0

    if [:up, :down].include? dir
      w = origin.w
      h = origin.h * (dir == :up ? size : -size)
    elsif [:left, :right].include? dir
      w = origin.w * (dir == :right ? size : -size)
      h = origin.h
    end
    
    [w, h]
  end

  def generate_wall_segments origin, count, dir
    # Origin x and y are tilemap position
    # They need to be converted to world space
    # by multiplying by tile_size
    tile_size  = [origin.w, origin.h]
    origin_pos = [origin.x * tile_size.x, origin.y * tile_size.y]

    size.times.map do |i|
      segment_pos = nil
      case dir
      when :up
        segment_pos = [origin_pos.x, origin_pos.y + (origin.h * i)]
      when :down
        segment_pos = [origin_pos.x, origin_pos.y - (origin.h * i)]
      when :right
        segment_pos = [origin_pos.x + (origin.w * i), origin_pos.y]
      when :left
        segment_pos = [origin_pos.x - (origin.w * i), origin_pos.y]
      end
      
      WallSegment.new(segment_pos, tile_size, self)
    end
  end

  def serialize
    { x: @x, y: @y, w: @w, h: @h, rgba: @rgba }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end

class WallSegment
  attr_reader :parent, :shape
  attr_sprite

  def initialize tile_pos, tile_size, parent_wall
    @x, @y = tile_pos
    @w, @h = tile_size
    @parent = parent_wall
  end

  def merge opts
    serialize.merge **opts
  end

  def serialize
    { x: @x, y: @y, w: @w, h: @h }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
