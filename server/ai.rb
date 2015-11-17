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

    while @team.ap > 0
      command = read_line

      is_valid = @team.check_bot_action(bot_number, command)
      if !is_valid
        abort("Command: #{command} is not valid!")
      end

      if command == "SHOOT"
        turn_log << ["SHOOT", x, y, @team.bots[bot_number].angle] #Only sending start position and angle back
      end

      @team.execute_bot_action(bot_number, command)
      data = populate_movement_data(bot_number, map)
      send_data(data) #Send data like new vision back to ai

      turn_log
    end
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
    sent_data = Array.new

    for line in data
      if line.is_a? Array
        array = Array.new
        for cell in line
          array << cell.to_s
        end

        sent_data << array
      else
        sent_data << line
      end
    end

    write(sent_data.to_s)
    flush
  end

  def process_vision (vision_array)
    array = Array.new
    for entity in vision_array
      entry = Array.new
      entry << entity.x
      entry << entity.y

      if entity.is_a? Bot
        entry << 1 #1 for bot
      elsif entity.is_a? Block
        entry << 2 #2 for block
      end

      array << entry
    end

    array
  end

  def read_line
    @bot_process.gets
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