# Extensions to core api. Numeric class changes, add Set class, etc.
require "lib/core/require.rb"

# A bunch of handy constants
require "lib/constants.rb"

# Color library
require "lib/colors/require.rb"

# Shape library
require "lib/shapes/require.rb"

# require "lib/arbor/arbor.rb"
require "lib/arbor/node.rb"
require "lib/arbor/entity.rb"

require "components/position.rb"
require "components/size.rb"
require "components/motion.rb"
require "components/sprite.rb"

# Wall object class
require "lib/wall.rb"

# Player entity class
require "lib/player.rb"

# Import and tick Game class
require "app/tick.rb"

# Final require
require "app/game.rb"
