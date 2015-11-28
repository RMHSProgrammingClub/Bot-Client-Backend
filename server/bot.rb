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
    #TODO: Implement raycasting crap
    #Temporarily just making a box
    start_x = 0
    start_y = 0
    end_x = 0
    end_y = 0

    case @angle
      when 315..360
        start_x = @x - $BOT_VISION
        start_y = @y
        end_x = @x + $BOT_VISION
        end_y = 0
      when 0..45 #Like -45 to 45
        start_x = @x - $BOT_VISION
        start_y = @y
        end_x = @x + $BOT_VISION
        end_y = 0
      when 45..135
        start_x = @x
        start_y = @y - $BOT_VISION
        end_x = $MAP_WIDTH - $BOT_VISION
        end_y = @y + $BOT_VISION
      when 135..225
        start_x = @x - $BOT_VISION
        start_y = @y
        end_x = @x + $BOT_VISION
        end_y = $MAP_HEIGHT - $BOT_VISION
      when 225..315
        start_x = @x
        start_y = @y - $BOT_VISION
        end_x = 0
        end_y = @y + $BOT_VISION
      else
        #this is bad
    end

    @vision = create_vision_box(start_x, start_y, end_x, end_y, map)
  end

  #All actions assume that AP has already been calculated
  def move (x, y, map)
    if !map.get(@x + x, @y + y).is_ghost
      @x += x
      @y += y
    end
  end

  def turn (degrees)
    @angle += degrees % 360
  end

  def shoot (map)
    nx = Math.cos(angle);
    ny = Math.sin(angle);
    is_hit = false

    bullet_x = @x
    while bullet_x < $MAP_WIDTH
      bullet_y = @y
      while bullet_y < $MAP_HEIGHT
        if map.get(bullet_x, bullet_y).is_destroyable
          map.get(bullet_x, bullet_y).hit
          is_hit = true
        end

        bullet_y += 1
      end

      if is_hit
        break
      end

      bullet_x += 1
    end
  end

  private
  def create_vision_box (start_x, start_y, end_x, end_y, map)
    box = Array.new

    map.map_array.each_with_index do |row, x|
      row.each_with_index do |cell, y|

        if x > start_x and x < end_x and y > start_y and y > end_y
          if cell.is_a? Bot or cell.is_a? Block
            box << cell
          end
        end
      end
    end

    box
  end
end