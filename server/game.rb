require_relative 'constants.rb'
require_relative 'ai.rb'
require_relative 'team.rb'
require_relative 'map.rb'

class Game
  attr_reader :turn_log

  # Class initializer
  def initialize
    @server_socket = TCPServer.new($SOCKET_PORT) # This is creates a socket server

    @map = Map.new
    @team1 = Team.new(1, @map.get_bots(1), @map.get_flag(1))
    @team2 = Team.new(2, @map.get_bots(2), @map.get_flag(2))
    @com1 = AI.new(@server_socket, @team1)
    @com2 = AI.new(@server_socket, @team2)
    @turn_log = Array.new
  end

  # Starts each client
  def start
    @com1.start
    @com2.start
  end

  # Runs the game. Goes through each turn and then saves the turn log
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

    @turn_log << @map.update # Update map once more because changes to be map are not reflected until the second update

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

  # Run a single turn
  def run_turn
    i = 0
    while i < $NUM_BOTS
      @turn_log = @com1.take_turn(i, @map, @turn_log)
      @turn_log = @com2.take_turn(i, @map, @turn_log)

      i += 1
    end
  end

  # Turns the turn log into a savable string
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