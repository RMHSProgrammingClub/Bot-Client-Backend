require 'socket'

require_relative 'constants.rb'

class AI
  def initialize (socket, team)
    @bot_socket = socket
    @team = team
  end

  def start
    @bot_client = @bot_socket.accept
    write("START")
    write(@team.number.to_s)
  end

  def stop
    @bot_client.close
  end

  def take_turn (bot_number, map, turn_log)
    write("START_TURN")
    @team.reset

    data = populate_movement_data(bot_number, map)
    send_data(data)

    command = ""
    while command != "END" and @team.ap > 0
      command = read_line

      if !@team.check_bot_action(bot_number, command)
        abort("Command: #{command} is not valid!")
      end

      @team.execute_bot_action(bot_number, command, map)
      if command == "SHOOT"
        turn_log << ["SHOOT", x, y, @team.bots[bot_number].angle] #Only sending start position and angle back
      end
    end

    turn_log
  end

  private
  def populate_movement_data (bot_number, map)
    #["START_DATA", bot_number, x, y, angle, [vision], "END_DATA"]

    data = Array.new
    data << @team.bots[bot_number].x
    data << @team.bots[bot_number].y
    data << @team.bots[bot_number].angle
    data << @team.bots[bot_number].health
    data << @team.ap
    @team.bots[bot_number].calculate_vision(map)
    data << process_vision(@team.bots[bot_number].vision)

    data
  end

  def send_data (data)
    to_send = ""
    for line in data
      to_send << "," + line.to_s
    end

    to_send.sub!(",", "") #Remove first comma

    write(to_send)
  end

  def process_vision (vision_array)
    output = ""
    for entity in vision_array
      entry = "["
      entry << entity.x.to_s + ","
      entry << entity.y.to_s + ","
      entry << entity.health.to_s + ","

      if entity.is_a? Bot and entity.is_dead
        entry << entity.angle.to_s + ","
        entry << 1.to_s #1 for bot
      elsif entity.is_a? Block
        if entity.is_breakable
          entry << 3.to_s #3 for block
        else
          entry << 2.to_s #2 for wall
        end
      end

      output << "," + entry + "]"
    end

    output.sub!(",", "")
    output
  end

  def read_line
    @bot_client.gets.chomp
  end

  def write (text)
    @bot_client.puts(text)
  end
end