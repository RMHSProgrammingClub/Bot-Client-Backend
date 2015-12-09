require_relative 'entity.rb'

# The class that is used when there is no other entity
class Air < Entity

  # Class initializer
  # x = starting x position
  # y = starting y position
  def initialize (x, y)
    super(x, y, 0, 0, false, true, 0)
  end

  # Used when turning the map into a string. Each entity has their own number
  # returns 0
  def to_number
    0
  end
end