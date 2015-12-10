# The class the controls all communication between the server and the client
class Connection
  attr_reader :socket

  # The class initializer
  # socket = the server socket
  def initialize (socket)
    @socket = socket
  end

  # Sends "START" and the team number to the client. This alerts the client so that it waits for its turn
  # team_number = the team number that the client is
  def start (team_number)
    @client = @socket.accept
    write("START")
    write(team_number.to_s)
  end

  # Closes the socket connection
  def stop
    @client.close
  end

  # Sends "START_TURN" to the client. This alerts the client so that it listens for the turn datas
  def start_turn
    write("START_TURN")
  end

  # Reads a line from the client
  # returns a string that was sent by the client
  def read_line
    @client.gets.chomp
  end

  # Writes a string to client
  # text = text to send
  def write (text)
    @client.puts(text)
  end

  # Sends turn data to the client
  # bot = the bot object who's turn it is
  # ap = the number of action points left
  def send_data (bot, ap, mana)
    data = Hash.new
    data["x"] = bot.x
    data["y"] = bot.y
    data["angle"] = bot.angle
    data["health"] = bot.health
    data["ap"] = ap
    data["mana"] = mana
    data["vision"] = process_vision(bot.vision)

    json = JSON.generate(data)

    write(json)
  end

  private

  # Turns the vision data from a bot into an array to be sent to the client
  # vision_array = the vision data from the bot
  # return the processed vision data
  def process_vision (vision_array)
    output = Array.new

    for entity in vision_array
      entry = Hash.new

      entry["type"] = ""
      if !entity.is_destroyed
        if entity.is_a? Bot
          entry["type"] = "BOT"
          entry["team"] = entity.team
        elsif entity.is_a? Wall
          entry["type"] =  "WALL"
        elsif entity.is_a? Block and !entity.is_a? Wall # Wall is an subclass of block
          entry["type"] = "BLOCK"
        elsif entity.is_a? Flag
          entry["type"] = "FLAG"
          entry["team"] = entity.team
        end
      end

      entry["x"] = entity.x
      entry["y"] = entity.y
      entry["angle"] = entity.angle
      entry["health"] = entity.health

      output << entry
    end

    output
  end
end