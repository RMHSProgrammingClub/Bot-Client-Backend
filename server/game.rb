require_relative 'constants.rb'
require_relative 'ai.rb'
require_relative 'team.rb'
require_relative 'block.rb'
require_relative 'flag.rb'

class Game
  attr_reader :turn_log
  def initialize (com1_file, com2_file)
    @map = generate_map
    flags = spawn_flags
    @team1 = Team.new(1, flags[0])
    @team2 = Team.new(2, flags[1])
    @com1 = AI.new(com1_file, @team1)
    @com2 = AI.new(com2_file, @team2)
    @turn_log = Array.new
  end

  def start
    @com1.start
    @com2.start
  end

  def run_turn
    i = 0

    while !@team1.flag.is_captured(@map) and !@team2.flag.is_captured(@map)
      while i < $NUM_BOTS
        @turn_log = @com1.take_turn(i, @map, @turn_log) #Turn log must be updated with any shoot commands
        @turn_log = @com2.take_turn(i, @map, @turn_log)
        proccess_map
      end
    end

    if !@team1.flag.is_captured(@map)
      puts "Team 1 has won!"
      @turn_log << "WIN_1"
    else
      puts "Team 2 has won!"
      @turn_log << "WIN_2"
    end
  end

  def generate_map
    new_map = Array.new

    #Build top and bottom barriers
    i = 0
    while i < $MAP_WIDTH
      new_map[i] = Array.new(0)
      new_map[i][0] = Block.new(i, 0, false)
      new_map[i][$MAP_WIDTH - 1] = Block.new(i, $MAP_WIDTH - 1, false)
      i += 1
    end

    #Build side barriers
    i = 0
    while i < $MAP_HEIGHT
      new_map[0][i] = Block.new(0, i, false)
      new_map[$MAP_WIDTH - 1][i] = Block.new($MAP_WIDTH - 1, i, false)
      i += 1
    end

    #TODO: Build stars

    new_map
  end

  def spawn_flags
    flags = Array.new

    flags[0] = Flag.new($MAP_WIDTH / 2, 1, 1)
    flags[1] = Flag.new($MAP_WIDTH / 2, $MAP_HEIGHT - 2, 2) # -2 should put the flag above the wall

    @map[flags[0].x][flags[0].y] = flags[0]
    @map[flags[1].x][flags[1].y] = flags[1]

    flags
  end

  #Turn map into drawable format
  def proccess_map
    new_drawable_map = Array.new

    @map.each_with_index do |row, x|
      new_drawable_map[x] = Array.new
      @map.each_with_index do |cell, y|
        if cell == 0
          new_drawable_map[x][y] = "0"
        elsif cell.is_a? Bot
          new_drawable_map[x][y] = "BOT"
        elsif cell.isa? Block
          new_drawable_map[x][y] = "BLOCK"
        end
      end
    end

    @turn_log << new_drawable_map
  end

  def save_game

  end
end