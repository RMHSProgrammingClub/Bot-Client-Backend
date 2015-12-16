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
  # bot = the bot
  # command = the command that the client sent
  # turn_number = the turn number of the game
  # returns weither the command is legal
  def check_bot_action (bot, command, map, turn_number)
    case command
      when /MOVE/
        if check_command_numbers("MOVE") then return false end
        if !check_ap($MOVEMENT_COST) then return false end
        x = command.split(" ")[1].to_i
        y = command.split(" ")[2].to_i
        if !bot.check_move(x, y, map) then return false end
      when "SHOOT"
        if !check_ap($SHOOT_COST) then return false end
        if !bot.check_shoot(turn_number) then return false end
      when /TURN/
        if check_command_numbers("TURN") then return false end
        degrees = command.split(" ")[1].to_i
        if !check_ap((degrees.to_d / $TURN_COST).ceil) then return false end # Round up ap cost so 1 degree turn costs 1 ap
        if !bot.check_turn(degrees) then return false end
      when /PLACE/
        if check_command_numbers("PLACE") then return false end
        if !check_ap($PLACE_COST) then return false end
        if !check_mana($PLACE_MANA_COST) then return false end
        x = command.split(" ")[1].to_i
        y = command.split(" ")[2].to_i
        if !bot.check_place(map, x, y) then return false end
      when /SPAWN/
        if !check_ap($SPAWN_COST) then return false end
        if !check_mana($SPAWN_MANA_COST) then return false end
        x = action.split(" ")[1].to_i
        y = action.split(" ")[2].to_i
        if !check_spawn_bot(x, y, map) then return false end
      else
        return false
    end

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
        @bots[bot_number].shoot(map)
      when /TURN/
        degrees = action.split(" ")[1].to_i
        @ap -= (degrees.to_d / $TURN_COST).ceil # Round up ap cost so 1 degree turn costs 1 ap
        @bots[bot_number].turn(degrees)
      when /PLACE/
        @ap -= $PLACE_COST
        @mana -= $PLACE_MANA_COST
        x = action.split(" ")[1].to_i
        y = action.split(" ")[2].to_i
        @bots[bot_number].place_block(map, x, y)
      when /SPAWN/
        @ap -= $SPAWN_COST
        @mana -= $SPAWN_MANA_COST
        x = action.split(" ")[1].to_i
        y = action.split(" ")[2].to_i
        spawn_bot(x, y, map)
    end
  end

  private

  # Spawns a new bot
  # map = the global map object
  def spawn_bot (x, y, map)
    bot = Bot.new(@number, @x + x, @y + y)
    @bots << bot
    map.set(@x + x, @y + y, bot)
    map.bots << bot
    bot.update(map)
  end

  # Check to see if bot is able spawn a new bot
  # map = the global map object
  def check_spawn_bot (x, y, map)
    if map.in_bounds(@x + x, @y + y) and map.get(@x + x, @y + y).is_ghost
      true
    else
      false
    end
  end

  # Check to see if there is only one command on a line
  # command = the line sent from the client
  def check_command_numbers (command)
    if command.scan(command).length == 1
      true
    else
      false
    end
  end

  # Check to see if bot has enough AP to carry out an action
  # cost = the cost of the specfic action
  def check_ap (cost)
    if @ap - cost >= 0
      true
    else
      false
    end
  end

  # Check to see if bot has enough mana to carry out an action
  # cost = the mana the action costs
  def check_mana (cost)
    if @mana - cost >= 0
      true
    else
      false
    end
  end
end