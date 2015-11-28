require_relative 'constants.rb'
require_relative 'bot.rb'

class Team
  attr_reader :number, :bots, :ap, :flag

  def initialize (number, bots, flag)
    @number = number
    @bots = bots
    @ap = $ACTION_POINTS
    @flag = flag
  end

  def check_bot_action (bot_number, command)
    #TODO: Implement action check
    true
  end

  def reset
    @ap = $ACTION_POINTS
  end

  # Command and ap requirement is already checked
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
      else
        #My god...
    end
  end
end