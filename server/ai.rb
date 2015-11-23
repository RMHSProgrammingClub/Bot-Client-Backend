require_relative 'constants.rb'

class AI
  def initialize (file, team)
    @bot_process = IO.popen("ruby #{file}", 'r+')
    @team = team
  end

  def start
    quick_write("START")
    quick_write(@team)
  end

  def stop
    @bot_process.close
  end

  def take_turn (bot_number, map, turn_log)
    quick_write("START_TURN")
    @team.reset

    # ["START_DATA", bot_number, x, y, angle, [vision], "END_DATA"]
    data = populate_movement_data(bot_number, map)
    send_data(data)

    while gets.chomp != "END" and @team.ap > 0
      command = read_line

      is_valid = @team.check_bot_action(bot_number, command)
      if !is_valid
        abort("Command: #{command} is not valid!")
      end

      @team.execute_bot_action(bot_number, command)
      if command == "SHOOT"
        turn_log << ["SHOOT", x, y, @team.bots[bot_number].angle] #Only sending start position and angle back
      end

      data = populate_movement_data(bot_number, map)
      send_data(data) #Send data like new vision back to ai
    end

    @team.reset

    turn_log
  end

  private
  def populate_movement_data (bot_number, map)
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
    for line in data
      if line.is_a? Array
        array = Array.new
        for cell in line
          array << cell.to_s
        end

        write(array)
      else
        write(line)
      end
    end

    flush
  end

  def process_vision (vision_array)
    output = ""
    for entity in vision_array
      entry = "["
      entry << entity.x.to_s + ","
      entry << entity.y.to_s + ","
      entry << entity.health.to_s + ","

      if entity.is_a? Bot
        entry << entity.angle.to_s + ","
        entry << 1.to_s #1 for bot
      elsif entity.is_a? Block
        if entity.is_breakable
          entry << 3.to_s #3 for block
        else
          entry << 2.to_s #2 for wall
        end
      end

      output << "," + entry
    end

    output << "]"
    output.sub!(",", "")
    output
  end

  def read_line
    @bot_process.gets.chomp
  end

  def quick_write (text)
    write(text)
    flush
  end

  def write (text)
    @bot_process.puts(text)
  end

  def flush
    @bot_process.flush
  end
end