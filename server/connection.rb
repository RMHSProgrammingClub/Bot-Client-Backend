require_relative 'constants.rb'

# The class the controls all communication between the server and the client
class Connection
  attr_reader :socket

  # The class initializer
  # socket = the server socket
  # team = the team object
  def initialize (socket, team)
    @socket = socket
    @team = team
  end

  # Sends "START" and the team number to the client. This alerts the client so that it waits for its turn
  def start
    @client = @socket.accept
    client_compliance = read_line # Check to make sure client is the correct version
    if client_compliance != $SERVER_VERSION
      write("Incorrect server compliance. Please update your api.")
      abort("A client has the wrong server comlpiance")
    end

    write("START")
    write(@team.number.to_s)
  end

  # Closes the socket connection
  def stop (winner)
    if winner == @team.number
      write("WIN")
    elsif winner == 0 # Draw
      write("DRAW")
    else
      write("LOSE")
    end

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
  def send_data (bot)
    data = Hash.new
    data["x"] = bot.x
    data["y"] = bot.y
    data["angle"] = bot.angle
    data["health"] = bot.health
    data["ap"] = @team.ap
    data["mana"] = @team.mana
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