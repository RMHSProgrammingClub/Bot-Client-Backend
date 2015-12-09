require_relative 'entity.rb'
require_relative 'constants.rb'

# The class that all bots are created with. Has all the methods that a client could be able to call
class Bot < Entity
  attr_reader :team, :vision

  # Class initializer
  # team = the team number of the bot
  # x = starting x position
  # y = starting y position
  def initialize (team, x, y)
    @team = team
    @old_x = x
    @old_y = y

    angle = 360
    if @team == 1
      angle = 180
    end

    super(x, y, angle, $BOT_HEALTH, true, false, $BOT_HIT_LOSS)
  end

  # Called when the map is updated. Removes its old object from the map and then sets a new one in its new position
  # map = the global map object
  def update (map)
    map.clear(@old_x, @old_y)
    map.set(@x, @y, self)
  end

  # Used when turning the map into a string. Each entity has their own number
  # returns the team number
  def to_number
    @team
  end

  # Calculates and stores what the bot can see
  # map = the global map object
  def calculate_vision (map)
    @vision = Array.new

    current_angle = @angle - ($FOV / 2) # Leftmost angle that the bot can see
    while current_angle < @angle + ($FOV / 2)
      entity = cast_line(current_angle, @x, @y, map)
      if !@vision.include?(entity)
        @vision << entity
      end

      current_angle += 1
    end
  end

  # All actions assume that AP has already been calculated

  # Called when the client sends "MOVE". Moves the bot
  # x = -1..1. Integer. The amount that the current x should be changed by
  # y = -1..1. Integer. The amount that the current y should be changed by
  # map = the global map object
  def move (x, y, map)
    new_x = @x + x
    new_y = @y + y

    if map.get(new_x, new_y).is_ghost
      @old_x = @x
      @old_y = @y

      @x = new_x
      @y = new_y
    end
  end

  # Called when the client sends "TURN". Turns the bot
  # degrees = the degrees that the current angle should be updated by
  def turn (degrees)
    @angle += degrees % 360
  end

  # Called when the client sends "SHOOTs". Shoots in the direction that the bot is facing
  # map = the global map object
  def shoot (map)
    entity = cast_line(@angle, @x, @y, map)

    if !entity.nil? and entity.team != @team
      entity.hit
    end
  end

  # Places a block
  # map = the global map object
  # x = -1..1. Integer. The amount that the current x should be changed by to place the block
  # y = -1..1. Integer. The amount that the current y should be changed by to place the block
  def place_block (map, x, y)
    if map.get(@x + x, @y + y).is_ghost
      map.set(@x + x, @y + y, Block.new(@x + x, @y + y, true))
    end
  end

  private

  # Converts degrees to radians
  # degrees = degrees to be converted to radians
  # returns radians
  def to_radians (degrees)
    degrees * Math::PI / 180 
  end

  # Creates a line and returns the first solid entity that it hits
  # angle = the angle the line should be cast
  # x = the start x
  # y = the start y
  # map = the global map object
  # returns the first solid entity to be hit
  def cast_line (angle, x, y, map)
    #nx = Math.cos(to_radians(angle))
    #ny = -Math.sin(to_radians(angle))
    nx = Math.sin(to_radians(angle))
    ny = Math.cos(to_radians(angle))

    line_x = x
    while line_x < $MAP_WIDTH
      line_y = y
      while line_y < $MAP_HEIGHT
        entity = map.get(line_x, line_y)
        if entity.is_a? Entity and !entity.is_ghost
          return map.get(line_x, line_y)
        end

        line_y += 1 * ny
      end

      line_x += 1 * nx
    end

    return nil
  end
end