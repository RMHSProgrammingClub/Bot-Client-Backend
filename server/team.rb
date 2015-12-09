require_relative 'constants.rb'
require_relative 'bot.rb'

# The class that contains each bot and executes action on that
class Team
  attr_reader :number, :bots, :ap, :flag, :mana

  # Class initializer
  # number = the team number
  # bots = the bots on that team
  # flag = the team's flag
  def initialize (number, bots, flag)
    @number = number
    @bots = bots
    @ap = $ACTION_POINTS
    @flag = flag
    @mana = $MAX_MANA
  end

  # Checks if the bot's action is legal
  # bot_number = the bot's number in the bots array
  # command = the command that the client sent
  # returns weither the command is legal
  def check_bot_action (bot_number, command)
    #TODO: Implement action check
    true
  end

  # Resets the action points and the mana
  def reset
    @ap = $ACTION_POINTS
    @mana += $MANA_PER_TURN
  end

  # Runs the command that the client sent
  # Command and ap requirement are already checked
  # bot_number = the number of the bot in the bots array
  # action = the command that the client sent
  # map = the global map object
  def execute_bot_action (bot_number, action, map)
    case action
      when /MOVE/
        @ap -= $MOVEMENT_COST
        x = action.split(" ")[1].to_i
        y = action.split(" ")[2].to_i
        @bots[bot_number].move(x, y, map)
      when "SHOOT"
        @ap -= $SHOOT_COST
        @bots[bot_number].shoot
      when /TURN/
        degrees = action.split(" ").to_i
        @ap -= degrees - $TURN_COST
        @bots[bot_number].turn(degrees)
      when /PLACE/
        @ap -= $PLACE_COST
        @mana -= $PLACE_MANA_COST
        x = action.split(" ")[1].to_i
        y = action.split(" ")[2].to_i
        @bots[bot_number].place_block(map, x, y)
      when "SPAWN"
        @ap -= $SPAWN_COST
        @mana -= $SPAWN_MANA_COST
        spawn_bot(@map)
      else
        #My god...
    end
  end

  private

  # Spawns a new bot
  # map = the global map object
  def spawn_bot (map)
    yPos = 10
    if @number == 2
      yPos = $MAP_HEIGHT - 10
    end

    bot = Bot.new(@number, $MAP_WIDTH / 2, yPos)
    @bots << bot
    @map.set($MAP_WIDTH / 2, yPos, bot)
    @map.bot << bot
  end
end