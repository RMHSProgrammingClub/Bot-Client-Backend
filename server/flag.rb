class Flag
  attr_reader :x, :y, :team
  def initialize (x, y, team)
    @x = x
    @y = y
    @team = team
  end

  def is_captured(map)
    #TODO: Implement capture logic
    points = get_surronding_points

    surronding_bots = 0
    for point in points
      if map[point[0]][point[1]].is_a? Bot
        surronding_bots += 1
      end
    end

    if surronding_bots >= $BOTS_TO_WIN
      true
    else
      false
    end
  end

  private
  def get_surronding_points
    points = Array.new

    points[0] = [x - 1, y]
    points[1] = [x + 1, y]

    if @team == 1
      points[2] = [x - 1, y + 1]
      points[3] = [x + 1, y + 1]
      points[4] = [x, y + 1]
    elsif @team == 2
      points[2] = [x - 1, y - 1]
      points[3] = [x + 1, y - 1]
      points[4] = [x, y - 1]
    end

    points
  end
end