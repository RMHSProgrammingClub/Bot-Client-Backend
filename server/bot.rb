require_relative 'constants.rb'

class Bot
  attr_reader :team, :x, :y, :angle, :vision

  def initialize (team, x, y)
    @team = team
    @x = x
    @y = y

    if @team == 1
      @angle = 180
    else
      @angle = 360
    end
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
        start_x = @x - 1
        start_y = @y
        end_x = @x + 1
        end_y = 0
      when 0..45 #Like -45 to 45
        start_x = @x - 1
        start_y = @y
        end_x = @x + 1
        end_y = 0
      when 45..135
        start_x = @x
        start_y = @y - 1
        end_x = $MAP_WIDTH - 1
        end_y = @y + 1
      when 135..225
        start_x = @x - 1
        start_y = @y
        end_x = @x + 1
        end_y = $MAP_HEIGHT - 1
      when 225..315
        start_x = @x
        start_y = @y - 1
        end_x = 0
        end_y = @y + 1
      else
        #this is bad
    end

    @vision = create_vision_box(start_x, start_y, end_x, end_y, map)
  end

  #All actions assume that AP has already been calculated
  def move_forward
    case @angle
      when 315..360
        @x += 1
      when 0..45 #Like -45 to 45
        @x += 1
      when 45..135
        @y += 1
      when 135..225
        @x -= 1
      when 225..315
        @y -= 1
      else
        #pls no
    end
  end

  def turn (degrees)
    @angle += degrees % 360
  end

  def shoot (map)
    #TODO: Implement shooting logic
  end

  private
  def create_vision_box (start_x, start_y, end_x, end_y, map)
    box = Array.new

    map.each_with_index do |row, x|
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