require_relative 'block.rb'

# The class for walls
class Wall < Block

  # Class initializer
  # x = starting x position
  # y = starting y position
  def initialize (x, y)
    super(x, y, false)
  end

  # Used when turning the map into a string. Each entity has their own number
  # returns 4
  def to_number
    '4'
  end
end