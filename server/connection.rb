class Connection
  attr_reader :socket

  def initialize (socket)
    @socket = socket
  end

  def start (team_number)
    @client = @socket.accept
    write("START")
    write(team_number.to_s)
  end

  def stop
    @client.close
  end

  def start_turn
    write("START_TURN")
  end

  def read_line
    @client.gets.chomp
  end

  def write (text)
    @client.puts(text)
  end

  def send_data (bot, ap)
    data = Hash.new
    data["x"] = bot.x
    data["y"] = bot.y
    data["angle"] = bot.angle
    data["health"] = bot.health
    data["ap"] = ap
    data["vision"] = process_vision(bot.vision)

    json = JSON.generate(data)

    write(json)
  end

  private
  def process_vision (vision_array)
    output = Array.new

    for entity in vision_array
      entry = Hash.new

      entry["type"] = ""
      if !entity.is_destroyed
        if entity.is_a? Bot
          entry["type"] = "BOT"
          entry["team"] = entity.team.to_s
        elsif entity.is_a? Wall
          entry["type"] =  "WALL"
        elsif entity.is_a? Block and !entity.is_a? Wall # Wall is an subclass of block
          entry["type"] = "BLOCK"
        end
      end

      entry["x"] = entity.x.to_s
      entry["y"] = entity.y.to_s
      entry["angle"] = entity.angle.to_s
      entry["health"] = entity.health.to_s

      output << entry
    end

    output
  end
end