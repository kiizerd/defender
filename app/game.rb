class Game
  attr_gtk

  def tick
    setup
    render

    # state.player.tick(args)
    input_vector = inputs.directional_vector
    state.player.move(*input_vector) if input_vector
  end

  def setup
    return if state.tick_count > 1

    state.defaults ||= { tile_size: 32 }
    state.map   ||= { tiles: generate_map_tiles }
    state.walls ||= [Wall.new(state.map.tiles[[5, 1]], 5, :right)]

    state.player ||= Player.new(x: grid.w.half, y: grid.h.half, w: 26, h: 30, rgba: BLUE)
  end

  def render
    outputs.solids << state.walls.map { |w| w.draw }

    outputs.solids << state.player
  end

  def generate_map_tiles
    tile_size = state.defaults.tile_size || 32
    (1280 / tile_size).to_i.times.map do |x|
      (720 / tile_size).to_i.times.map do |y|
        [[x, y], { x: x, y: y, w: tile_size, h: tile_size }]
      end
    end.flatten(1).to_h # Only flatten 1 level deep
  end
end
