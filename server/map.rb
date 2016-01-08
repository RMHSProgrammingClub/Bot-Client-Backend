require_relative 'air.rb'
require_relative 'block.rb'
require_relative 'wall.rb'
require_relative 'flag.rb'
require_relative 'bot.rb'
require_relative 'constants.rb'

# The map class that controls all map operations
class Map
  attr_reader :map_array, :map_changes, :bots, :flags, :walls

  # Class initializer
  def initialize
    @map_array = generate_map
    @map_changes = Array.new
  end

  # Gets the entity from the map_array
  # x = the x position
  # y = the y position
  # returns an entity
  def get (x, y)
    @map_array[y][x]
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
          entities << get(on_x, on_y)
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
    if in_bounds(x, y)
      @map_array[y][x] = value # y then x because the array is formatted row (y) and then column (x)
      @map_changes << value
    else
      abort("Something tried to move way outside to map")
    end
  end

  # Makes a point air
  # x = the x position
  # y = the y position
  def clear (x, y)
    if in_bounds(x, y)
      set(x, y, Air.new(x, y))
    else
      abort("Something tried to move way outside to map")
    end
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

  # Checks to see if inputed x and y values are inside the map
  # x = the x position (or the column)
  # y = the y position (or the row)
  def in_bounds (x, y)
    if in_x_bounds(x) and in_y_bounds(y)
      true
    else
      false
    end
  end

  def in_x_bounds (x)
    if x.between?(0, $MAP_WIDTH - 1)
      true
    else
      false
    end
  end

  def in_y_bounds (y)
    if y.between?(0, $MAP_HEIGHT - 1)
      true
    else
      false
    end
  end

  # Updates turns the map into a drawable string
  # returns a string of the map in number
  def to_string (prev_string)
    #0 = empty, 1 = team 1 bot, 2 = team 2 bot, 3 = block, 4 = wall, 5 = flag
    if prev_string.nil? # First run through
      new_drawable_map = ""
      for row in @map_array
        for col in row
          new_drawable_map << col.to_number
        end
      end
    else
      new_drawable_map = prev_string

      for change in @map_changes
        new_index = change.x * change.y
        old_index = change.old_x * change.old_y

        new_drawable_map[new_index] = change.to_number
        new_drawable_map[old_index] = "0" # TODO: only change to air if nothing else is there
      end

      @map_changes = Array.new
    end

    new_drawable_map
  end

  private

  # Generates an empty map that is filled with air
  # returns the newly created map
  def generate_empty_map
    new_map = Array.new

    #Build empty space
    col = 0
    row = 0
    while in_bounds(col, row)
      new_map[row] = Array.new

      while in_bounds(col, row)
        new_map[row][col] = Air.new(row, col)
        col += 1
      end

      col = 0
      row += 1
    end

    new_map
  end

  # Creates walls onto the map
  # map = the map to add walls to
  # returns the map with walls
  def generate_walls (map)
    @walls = Array.new

    #Build top and bottom walls
    col = 0
    while in_x_bounds(col)
      wall1 = Wall.new(col, 0)
      wall2 = Wall.new(col, $MAP_HEIGHT - 1)

      map[0][col] = wall1
      map[$MAP_HEIGHT - 1][col] = wall2

      @walls << wall1
      @walls << wall2

      col += 1
    end

    #Build side walls
    row = 0
    while in_y_bounds(row)
      wall1 = Wall.new(0, row)
      wall2 = Wall.new($MAP_WIDTH - 1, row)

      map[row][0] = wall1
      map[row][$MAP_WIDTH - 1] = wall2

      @walls << wall1
      @walls << wall2

      row += 1
    end

    map
  end

  # Generates blocks onto the map
  # map = the map to add blocks to
  # returns the map with blocks
  def generate_blocks (map)
    blocks = 0
    while blocks < $NUM_BLOCKS
      rand_row = Random.rand($MAP_HEIGHT / 3..$MAP_HEIGHT - ($MAP_HEIGHT / 3)) # Only spawn block in the middlish
      rand_col = Random.rand($MAP_WIDTH)

      if map[rand_row][rand_col].is_a? Air
        map[rand_row][rand_col] = Block.new(rand_row, rand_col, true)
        blocks += 1
      end
    end

    map
  end

  # Spawn flags onto the map at opposite ends of the map
  # map = the map to add flags to
  # returns the newly created flags, and the map with flags on it
  def spawn_flags (map)
    flags = Array.new

    flags[0] = Flag.new($MAP_WIDTH / 2, 1, 1)
    flags[1] = Flag.new($MAP_WIDTH / 2, $MAP_HEIGHT - 2, 2) # -2 should put the flag above the wall

    map[flags[0].y][flags[0].x] = flags[0]
    map[flags[1].y][flags[1].x] = flags[1]

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
      bots[0][i] = Bot.new(1, (i + 1) * $BOT_SPACING, $BOT_SPACING - 2)
      bots[1][i] = Bot.new(2, ((i + 1) * $BOT_SPACING) + 2, $MAP_HEIGHT - $BOT_SPACING)

      map[bots[0][i].y][bots[0][i].x] = bots[0][i]
      map[bots[1][i].y][bots[1][i].x] = bots[1][i]
      i += 1
    end

    return bots, map
  end
end