require_relative 'constants.rb'
require_relative 'ai.rb'
require_relative 'team.rb'
require_relative 'block.rb'
require_relative 'flag.rb'

class Game
  attr_reader :turn_log
  def initialize
    @server_socket = TCPServer.open("localhost", $SOCKET_PORT) # This is creates a socket server

    @map = generate_map
    flags = spawn_flags
    @team1 = Team.new(1, flags[0])
    @team2 = Team.new(2, flags[1])
    @com1 = AI.new(@server_socket, @team1)
    @com2 = AI.new(@server_socket, @team2)
    @turn_log = Array.new
  end

  def start
    @com1.start
    @com2.start
  end

  def run
    turn_number = 0
    while !@team1.flag.is_captured(@map) and !@team2.flag.is_captured(@map)
      if turn_number >= $MAX_TURNS
        break
      else
        puts "Running turn " + turn_number.to_s
        run_turn
      end

      turn_number += 1
    end

    if !@team1.flag.is_captured(@map) and @team2.flag.is_captured(@map)
      puts "Game ended with team 1 winning"
      @turn_log << "WIN1"
    elsif @team1.flag.is_captured(@map) and !@team2.flag.is_captured(@map)
      puts "Game ended with team 2 winning"
      @turn_log << "WIN2"
    else
      puts "Game ended in a draw"
      @turn_log << "DRAW"
    end

    puts "Processing turn log"
    game_data = process_turn_log

    puts "Saving turn log"
    game_file = File.new("game.txt", "w")
    game_file.puts game_data
  end

  def run_turn
    i = 0
    while i < $NUM_BOTS
      @turn_log = @com1.take_turn(i, @map, @turn_log) #Turn log must be updated with any shoot commands
      proccess_map

      @turn_log = @com2.take_turn(i, @map, @turn_log)
      proccess_map

      i += 1
    end
  end

  def generate_map
    new_map = Array.new

    #Build empty space
    x = 0
    while x < $MAP_WIDTH
      new_map[x] = Array.new

      y = 0
      while y < $MAP_HEIGHT
        new_map[x][y] = 0
        y += 1
      end

      x += 1
    end

    #Build top and bottom barriers
    i = 0
    while i < $MAP_WIDTH
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
  #This is really slow right now
  def proccess_map
    #0 = empty, 1 = team 1 bot, 2 = team 2 bot, 3 = block, 4 = wall
    new_drawable_map = ""

    for row in @map
      for cell in row
        if cell == 0
          new_drawable_map << "0" #Nothing
        elsif cell.is_a? Bot
          new_drawable_map << cell.team.to_s #Bot can be 1 or 2 depending on team number
        elsif cell.is_a? Block
          if cell.is_breakable
            new_drawable_map << "3" #Block
          else
            new_drawable_map << "4" #Wall
          end
        end
      end
    end

    @turn_log << new_drawable_map
  end

  def process_turn_log
    string_turn_log = ""

    i = 0
    while i < @turn_log.length
      string_turn_log << @turn_log[i] + "\n"
      i += 1

      shot_log = ""
      while i < @turn_log.length and @turn_log[i].include?("SHOOT")
        puts "Shoot"
        shot_log << " " + @turn_log[i]
        i += 1
      end
      shot_log.sub!(" ", "") #Remove start space

      string_turn_log << shot_log + "\n"
    end

    string_turn_log
  end
end