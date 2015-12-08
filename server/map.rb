require_relative 'air.rb'
require_relative 'block.rb'
require_relative 'wall.rb'
require_relative 'flag.rb'
require_relative 'bot.rb'
require_relative 'constants.rb'

class Map
  attr_reader :map_array

  def initialize
    @map_array = generate_map
  end

  def get (x, y)
    @map_array[x][y]
  end

  def get_all_bots
    @bots
  end

  def get_all_flags
    @flags
  end

  def get_bots (team_number)
    @bots[team_number - 1] #team 1 -> 0
  end

  def get_flag (team_number)
    @flags[team_number - 1]  #team 1 -> 0
  end

  def get_surronding_entities (x, y)
    entities = Array.new
    end_x = x + 1
    end_y = y + 1

    on_x = x - 1
    while on_x <= end_x
      on_y = y - 1
      while on_y <= end_y
        if on_x != x and on_y != y #Ignore the middle entity
          entities << @map_array[on_x][on_y]
        end
        on_y += 1
      end
      on_x += 1
    end

    entities
  end

  def set (x, y, value)
    @map_array[x][y] = value
  end

  def generate_map
    new_map = generate_empty_map

    new_map = generate_walls(new_map)
    new_map = generate_blocks(new_map)

    @flags, new_map = spawn_flags(new_map)
    @bots, new_map = spawn_bots(new_map)

    new_map
  end

  def update_map
    new_map = generate_empty_map
    mew_map = generate_walls(new_map)

    for flag in @flags
      new_map[flag.x][flag.y] = flag
    end

    for bot_team in @bots
      for bot in bot_team
        new_map[bot.x][bot.y] = bot
      end
    end

    @map_array = new_map
  end

  def to_string
    #0 = empty, 1 = team 1 bot, 2 = team 2 bot, 3 = block, 4 = wall
    new_drawable_map = ""

    for row in @map_array
      for cell in row
        if cell.is_a? Bot
          new_drawable_map << cell.team.to_s #Bot can be 1 or 2 depending on team number
        elsif cell.is_a? Wall
          new_drawable_map << "4" #Wall
        elsif cell.is_a? Block
            new_drawable_map << "3" #Block
        else
          new_drawable_map << "0" #Nothing
        end
      end
    end

    new_drawable_map
  end

  private
  def generate_empty_map
    new_map = Array.new

    #Build empty space
    x = 0
    while x < $MAP_WIDTH
      new_map[x] = Array.new

      y = 0
      while y < $MAP_HEIGHT
        new_map[x][y] = Air.new(x, y)
        y += 1
      end

      x += 1
    end

    new_map
  end

  def generate_walls (map)
    #Build top and bottom walls
    x = 0
    while x < $MAP_WIDTH
      map[x][0] = Wall.new(x, 0)
      map[x][$MAP_HEIGHT - 1] = Wall.new(x, $MAP_HEIGHT - 1)
      x += 1
    end

    #Build side walls
    y = 0
    while y < $MAP_HEIGHT
      map[0][y] = Wall.new(0, y)
      map[$MAP_WIDTH - 1][y] = Wall.new($MAP_WIDTH - 1, y)
      y += 1
    end

    map
  end

  def generate_blocks (map)
    #TODO: Build stars

    map
  end

  def spawn_flags (map)
    flags = Array.new

    flags[0] = Flag.new($MAP_WIDTH / 2, 1, 1)
    flags[1] = Flag.new($MAP_WIDTH / 2, $MAP_HEIGHT - 2, 2) # -2 should put the flag above the wall

    map[flags[0].x][flags[0].y] = flags[0]
    map[flags[1].x][flags[1].y] = flags[1]

    return flags, map
  end

  def spawn_bots (map)
    bots = Array.new
    bots[0] = Array.new
    bots[1] = Array.new

    i = 0
    while i < $NUM_BOTS
      bots[0][i] = Bot.new(1, (i + 1) * $BOT_SPACING, $BOT_SPACING)
      bots[1][i] = Bot.new(2, (i + 1) * $BOT_SPACING, $MAP_HEIGHT - $BOT_SPACING)

      map[bots[0][i].x][bots[0][i].y] = bots[0][i]
      map[bots[1][i].x][bots[1][i].y] = bots[1][i]
      i += 1
    end

    return bots, map
  end
end