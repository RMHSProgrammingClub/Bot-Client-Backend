require 'socket'
require 'json'

require_relative 'constants.rb'
require_relative 'connection.rb'

class AI

  def initialize (socket, team)
    @team = team
    @connection = Connection.new(socket)
  end

  def start
    @connection.start(@team.number)
  end

  def stop
    @connection.close
  end

  def take_turn (bot_number, map, turn_log)
    @connection.start_turn
    @team.reset

    bot = @team.bots[bot_number]
    bot.calculate_vision(map)
    @connection.send_data(bot, @team.ap)

    command = ""
    while command != "END" and @team.ap > 0
      command = @connection.read_line

      if !@team.check_bot_action(bot_number, command)
        abort("Command: #{command} is not valid!")
      end

      @team.execute_bot_action(bot_number, command, map)
      if command == "SHOOT"
        turn_log << ["SHOOT", x, y, @team.bots[bot_number].angle] #Only sending start position and angle back
      end

      turn_log << map.update
    end

    turn_log
  end
end