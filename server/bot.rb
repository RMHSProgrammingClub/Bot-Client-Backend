require 'pry'

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

    angle = 0
    if @team == 2
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

    for row in map.map_array
      for cell in row
        if !cell.is_ghost # If it is possible to walk through it then you cannot see it
          angle_between = normilize_angle(calculate_angle(@x, @y, cell.x, cell.y))

          if angle_between.between?($FOV / 2, $FOV + ($FOV / 2))
            entity_between = cast_line(@x.to_f, @y.to_f, cell.x.to_f, cell.y.to_f, map)

            if cell == entity_between
              @vision << cell
            end
          end
        end
      end
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

  # Check to see if bot is able to move
  # x = x position modifier
  # y = y position modifier
  # map = global map object
  # returns weither the action is valid
  def check_move (x, y, map)
    if x.between?(-1, 1) and y.between?(-1, 1) and map.get(@x + x, @y + y).is_a? Air
      true
    else
      false
    end
  end

  # Called when the client sends "TURN". Turns the bot
  # degrees = the degrees that the current angle should be updated by
  def turn (degrees)
    @angle += degrees
    @angle %= 360
  end

  # Check to see if bot is able to turn
  # degrees = degrees to turn by
  # returns weither the action is valid
  def check_turn (degrees)
    if degrees != 0
      true
    else
      false
    end
  end

  # Called when the client sends "SHOOT". Shoots in the direction that the bot is facing
  # map = the global map object
  def shoot (map)
    entity = cast_line(@angle, @x, @y, map)

    if !entity.nil? and entity.team != @team
      entity.hit
    end
  end

  # Check to see if bot is able to shoot
  # turn_number = the turn number of the game
  # returns weither the action is valid
  def check_shoot (turn_number)
    if !turn_number.between?(0, $TURNS_INVULN)
      true
    else
      false
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

  # Check to see if bot is able to place block
  # map = the global map object
  # x = the x position modifier
  # y = the y position modifier
  # returns weither the action is valid
  def check_place (map, x, y)
    if map.get(@x + x, @y + y).is_a? Air
      true
    else
      false
    end
  end

  private

  # Normilizes an angle to make it in between 0 and 360
  # angle = an angle that is -Infinity - Infinity
  # returns an angle 0 - 360
  def normilize_angle (angle)
    (360 + angle % 360) % 360
  end

  # Calculates angle between two points
  # x1 = first x position
  # y1 = first y position
  # x2 = second x position
  # y2 = second y position
  # returns the angle inbetween the two points
  def calculate_angle (x1, y1, x2, y2)
    delta_x = x2 - x1
    delta_y = y2 - y1

    Math.atan2(delta_y, delta_x) * 180 / Math::PI
  end

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
  def cast_line (x1, y1, x2, y2, map)
    slope = (x2 - x1) / (y2 - y1)

    line_y = y1
    while map.in_y_bounds(line_y)
      line_x = x1 + (slope * (line_y - y1))

      entity = map.get(line_x.to_i, line_y.to_i)
      if entity != self and !entity.is_ghost
        return entity
      end

      line_y += 1
    end

    abort("Bot cannot see anything?")
  end
end