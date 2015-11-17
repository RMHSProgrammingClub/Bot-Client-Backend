require_relative 'constants.rb'
require_relative 'ai.rb'
require_relative 'team.rb'
require_relative 'block.rb'

class Game
  def initialize (com1_file, com2_file)
    @map = generate_map
    @team1 = Team.new(1)
    @team2 = Team.new(2)
    @com1 = AI.new(com1_file, @team1)
    @com2 = AI.new(com2_file, @team2)
  end

  def start
    @com1.start
    @com2.start
  end

  def run_turn
    i = 0

    while i < $NUM_BOTS
      @com1.take_turn(i, @map)
      @com2.take_turn(i, @map)
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

  #Turn map into drawable format
  def proccess_map
    @drawable_map = Array.new

    @map.each_with_index do |row, x|
      @drawable_map[x] = Array.new
      @map.each_with_index do |cell, y|
        if cell == 0
          @drawable_map[x][y] = "0"
        elsif cell.is_a? Bot
          @drawable_map[x][y] = "BOT"
        elsif cell.isa? Block
          @drawable_map[x][y] = "BLOCK"
        end
      end
    end
  end

  def print_drawable_map
    puts @drawable_map.to_s
  end
end