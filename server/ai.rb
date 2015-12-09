require 'socket'
require 'json'

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
    write(data)

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

    map.update_map

    turn_log
  end

  private
  def populate_movement_data (bot_number, map)
    data = Hash.new
    data["x"] = @team.bots[bot_number].x
    data["y"] = @team.bots[bot_number].y
    data["angle"] = @team.bots[bot_number].angle
    data["health"] = @team.bots[bot_number].health
    data["ap"] = @team.ap
    @team.bots[bot_number].calculate_vision(map)
    data["vision"] = process_vision(@team.bots[bot_number].vision)

    json = JSON.generate(data)

    json
  end

  def process_vision (vision_array)
    output = Array.new
    for entity in vision_array
      entry = Hash.new

      entry["type"] = ""
      if entity.is_a? Bot and !entity.is_destroyed
        entry["type"] = "BOT"
        entry["team"] = entity.team.to_s
      elsif entity.is_a? Wall
        entry["type"] =  "WALL"
      elsif entity.is_a? Block and !entity.is_a? Wall
        entry["type"] = "BLOCK"
      end

      entry["x"] = entity.x.to_s
      entry["y"] = entity.y.to_s
      entry["angle"] = entity.angle.to_s
      entry["health"] = entity.health.to_s

      output << entry
    end

    output
  end

  def read_line
    @bot_client.gets.chomp
  end

  def write (text)
    @bot_client.puts(text)
  end
end