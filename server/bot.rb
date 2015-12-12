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

    angle = 90
    if @team == 2
      angle = 270
    end
    @vision = Array.new

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

    leftmost_angle = @angle - ($FOV / 2)
    rightmost_angle = @angle + ($FOV / 2)

    for row in map.map_array
      for cell in row
        if !cell.is_ghost # If it is possible to walk through it then you cannot see it
          angle_between = calculate_angle(@x, @y, cell.x, cell.y)

          if angle_between.between?(leftmost_angle, rightmost_angle)
            entity_between = draw_line(@x.to_f, @y.to_f, cell.x.to_f, cell.y.to_f, map)

            if cell == entity_between
              if !@vision.include? cell
                @vision << cell
              end
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

      update(map)
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
    entity = draw_line_from_angle(@x, @y, @angle, map)

    if !entity.nil? and entity.team != @team
      entity.hit(map)
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

  # Calculates angle between two points
  # x1 = first x position
  # y1 = first y position
  # x2 = second x position
  # y2 = second y position
  # returns the angle inbetween the two points
  def calculate_angle (x1, y1, x2, y2)
    delta_x = x2 - x1
    delta_y = y2 - y1

    to_degrees(Math.atan2(delta_y, delta_x))
  end

  # Converts degrees to radians
  # degrees = degrees to be converted to radians
  # returns radians
  def to_radians (degrees)
    degrees * (3.14 / 180)
  end

  # Converts radians to degrees
  # radians = radians to be converted to degrees
  # returns degrees
  def to_degrees (radians)
    radians * (180 / 3.14)
  end

  # Creates a line from two points and returns the first solid entity that it hits
  # x1 = the start x
  # y1 = the start y
  # x2 = the end x
  # y2 = the end y
  # map = the global map object
  # returns the first solid entity to be hit
  def draw_line (x1, y1, x2, y2, map)
    slope = (x2 - x1) / (y2 - y1)

    line_x = 0
    line_y = y1
    while map.in_bounds(line_x, line_y)
      line_x = x1 + (slope * (line_y - y1))

      entity = map.get(line_x, line_y)
      if !entity.is_ghost and entity != self
        return entity
      end

      line_y += 1
    end

    abort("Bot cannot see anything?")
  end


  # Creates a line from an angle and returns the first solid entity that it hits
  # x = the start x
  # y = the start y
  # angle = the angle to draw the line at
  # map = the global map object
  # returns the first solid entity to be hit
  def draw_line_from_angle (x, y, angle, map)
    dx = Math.cos(to_radians(angle))
    dy = -Math.sin(to_radians(angle))
    line_x = x
    line_y = y

    while map.in_bounds(line_x, line_y)
      entity = map.get(line_x.to_i, line_y.to_i)
      if entity != self and !entity.is_ghost
        return entity
      end

      line_x += dx
      line_y += dy
    end
  end
end