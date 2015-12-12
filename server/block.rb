require_relative 'entity.rb'
require_relative 'constants.rb'

# Used for randomly generated objects and spawn objects
class Block < Entity

  # Class initializer
  # x = starting x position
  # y = starting y position
  # is_destroyable = weither a bot is able to destroy it
  def initialize (x, y, is_destroyable)
    super(x, y, 0, $BLOCK_HEALTH, is_destroyable, false, $BLOCK_HIT_LOSS)
  end

  # Used when turning the map into a string. Each entity has their own number
  # returns 3
  def to_number
    "3"
  end
end