require_relative 'entity.rb'
require_relative 'constants.rb'

class Bot < Entity
  attr_reader :team, :vision

  def initialize (team, x, y)
    @team = team

    angle = 360
    if @team == 1
      angle = 180
    end

    super(x, y, angle, $BOT_HEALTH, true, false)
  end

  def calculate_vision (map)
    @vision = Array.new

    current_angle = @angle - ($FOV / 2)
    while current_angle < @angle + ($FOV / 2)
      entity = cast_line(current_angle, @x, @y, map)
      if !@vision.include?(entity)
        @vision << entity
      end

      current_angle += 1
    end
  end

  #All actions assume that AP has already been calculated
  def move (x, y, map)
    if map.get(@x + x, @y + y).is_ghost
      @x += x
      @y += y
    end
  end

  def turn (degrees)
    @angle += degrees % 360
  end

  def shoot (map)
    entity = cast_line(@sangle, @x, @y, map)

    if !entity.nil? and entity.team != @team
      entity.hit
    end
  end

  def place_block (map, x, y)
    if map.get(@x + x, @y + y).is_ghost
      map.set(@x + x, @y + y, Block.new(@x + x, @y + y, true))
    end
  end

  private
  def to_radians (degrees)
    degrees * Math::PI / 180 
  end

  def cast_line (angle, x, y, map)
    nx = Math.cos(to_radians(angle))
    ny = -Math.sin(to_radians(angle))
    is_hit = false

    line_x = x
    while line_x < $MAP_WIDTH
      line_y = y
      while line_y < $MAP_HEIGHT
        if map.get(line_x, line_y).is_a? Entity
          return map.get(line_x, line_y)
        end

        line_y += 1
      end

      line_x += 1
    end

    return nil
  end
end