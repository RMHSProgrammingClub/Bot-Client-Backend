require_relative 'air.rb'
require_relative 'block.rb'
require_relative 'wall.rb'
require_relative 'flag.rb'
require_relative 'bot.rb'
require_relative 'constants.rb'

# The map class that controls all map operations
class Map
  attr_reader :map_array, :bots, :flags

  # Class initializer
  def initialize
    @map_array = generate_map
  end

  # Gets the entity from the map_array
  # x = the x position
  # y = the y position
  # returns an entity
  def get (x, y)
    @map_array[x][y]
  end

  # Get all bots in a specific team
  # team_number = the team number of the bots you want to get
  # returns an array of the bots on that team
  def get_bots (team_number)
    @bots[team_number - 1] #team 1 -> 0
  end

  # Get the flag of a specific team
  # team_number = the team number of the flag you want to get
  # returns a flag
  def get_flag (team_number)
    @flags[team_number - 1]  #team 1 -> 0
  end

  # Get all entities (including air), that surronds a point
  # x = the x position
  # y = the y position
  # returns an array of entities
  def get_surronding_entities (x, y)
    entities = Array.new
    end_x = x + 1
    end_y = y + 1

    on_x = x - 1
    while on_x <= end_x
      on_y = y - 1
      while on_y <= end_y
        if on_x != x and on_y != y # Ignore the middle entity
          entities << @map_array[on_x][on_y]
        end
        on_y += 1
      end
      on_x += 1
    end

    entities
  end

  # Set a point to an object
  # x = the x position
  # y = the y position
  # value = the object that the point is set to
  def set (x, y, value)
    @map_array[x][y] = value
  end

  # Makes a point air
  # x = the x position
  # y = the y position
  def clear (x, y)
    @map_array[x][y] = Air.new(x, y)
  end

  # Generates the starting map with walls, bots, and flags
  # returns the newly created map
  def generate_map
    new_map = generate_empty_map

    new_map = generate_walls(new_map)
    new_map = generate_blocks(new_map)

    @flags, new_map = spawn_flags(new_map)
    @bots, new_map = spawn_bots(new_map)

    new_map
  end

  # Updates every entities position and turns the map into a drawable string
  # returns a string of the map in number
  def update
    #0 = empty, 1 = team 1 bot, 2 = team 2 bot, 3 = block, 4 = wall, 5 = flag
    new_drawable_map = ""

    for row in @map_array
      for cell in row
        new_drawable_map << cell.to_number.to_s
        cell.update(self)
      end
    end

    new_drawable_map
  end

  private

  # Generates an empty map that is filled with air
  # returns the newly created map
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

  # Creates walls onto the map
  # map = the map to add walls to
  # returns the map with walls
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

  # Generates blocks onto the map
  # map = the map to add blocks to
  # returns the map with blocks
  def generate_blocks (map)
    #TODO: Build stars

    map
  end

  # Spawn flags onto the map at opposite ends of the map
  # map = the map to add flags to
  # returns the newly created flags, and the map with flags on it
  def spawn_flags (map)
    flags = Array.new

    flags[0] = Flag.new(1, $MAP_HEIGHT / 2, 1)
    flags[1] = Flag.new($MAP_WIDTH - 2, $MAP_HEIGHT / 2, 2) # -2 should put the flag above the wall

    map[flags[0].x][flags[0].y] = flags[0]
    map[flags[1].x][flags[1].y] = flags[1]

    return flags, map
  end

  # Spawn bots onto the map at opposite ends of the map per team
  # map = the map to add bots to
  # returns an array of newly created bots, and the map with bots on it
  def spawn_bots (map)
    bots = Array.new
    bots[0] = Array.new
    bots[1] = Array.new

    i = 0
    while i < $NUM_BOTS
      bots[0][i] = Bot.new(1, $BOT_SPACING, (i + 1) * $BOT_SPACING - 2)
      bots[1][i] = Bot.new(2, $MAP_WIDTH - $BOT_SPACING, ((i + 1) * $BOT_SPACING) + 2)

      map[bots[0][i].x][bots[0][i].y] = bots[0][i]
      map[bots[1][i].x][bots[1][i].y] = bots[1][i]
      i += 1
    end

    return bots, map
  end
end