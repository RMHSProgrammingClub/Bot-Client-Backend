require_relative 'constants.rb'
require_relative 'bot.rb'

class Team
  attr_reader :number, :bots, :ap, :flag

  def initialize (number, flag)
    @number = number
    @bots = spawn_bots
    @ap = $ACTION_POINTS
    @flag = flag
  end

  def spawn_bots
    y = 0
    if @number == 1
      y = 10
    else
      y = 502
    end

    bot_team = Array.new

    i = 0
    while i <= $NUM_BOTS
      bot_team[i] = Bot.new(@number, i * $BOT_SPACING, y)
      i += 1
    end

    bot_team
  end

  def check_bot_action (bot_number, command)
    #TODO: Implement action check
  end

  def reset
    @ap = $ACTION_POINTS
  end

  # Command and ap requirement is already checked
  def execute_bot_action (bot_number, action)
    case action
      when "FORWARD"
        @ap -= $MOVEMENT_COST
        @bots[bot_number].move_forward
      when "STRAFE_LEFT"
        @ap -= $MOVEMENT_COST
        @bots[bot_number].strafe_left
      when "STRAFE_RIGHT"
        @ap -= $MOVEMENT_COST
        @bots[bot_number].strafe_right
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