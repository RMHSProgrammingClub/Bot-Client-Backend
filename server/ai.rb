require 'socket'
require 'json'

require_relative 'constants.rb'
require_relative 'connection.rb'

# This class controls each team's ai
class AI

  # Class initializer
  # socket = the server socket
  # team = the ai's team object
  def initialize (socket, team)
    @team = team
    @connection = Connection.new(socket, team)
  end

  # Start the client
  def start
    @connection.start
  end

  # Stop the client
  # winner = the team number of the winner
  def stop (winner)
    @connection.stop(winner)
  end

  # Take a turn
  # bot_number = the number of the bot whose turn it is
  # map = the global map object
  # turn_log = the global log of both maps and shots from each turn
  # turn_number = the turn number of the game
  def take_turn (bot_number, map, turn_log, turn_number)
    @connection.start_turn
    @team.reset

    bot = @team.bots[bot_number]
    bot.calculate_vision(map)
    @connection.send_data(bot)

    command = @connection.read_line

    prev_map = map.to_string(prev_map)

    turn_log << prev_map
    while !command.include?("END") and @team.ap > 0
      if @team.check_bot_action(bot, command, map, turn_number) # Only execute actions if the move is valid
        @team.execute_bot_action(bot, command, map)

        if command == "SHOOT"
          turn_log << bot.x.to_s + "," + bot.y.to_s + "," + bot.angle.to_s # Only sending start position and angle back
        end
      else
        puts "Command: #{command} is not valid!"
      end

      command = @connection.read_line
    end

    turn_log
  end
end