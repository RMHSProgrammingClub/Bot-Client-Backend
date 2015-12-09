require_relative 'entity.rb'

# The flag class. Each team has one
class Flag < Entity
  attr_reader :team

  # Class initializer
  # x = starting x position
  # y = starting y position
  # team = the team number of the bot
  def initialize (x, y, team)
    @team = team

    super(x, y, 0, 0, false, false)
  end

  # Checks if the flag has been captured
  # map = the global class object
  # returns weither the flag has been captured or not
  def is_captured (map)
    entities = map.get_surronding_entities(@x, @y)

    surronding_bots = 0
    for entity in entities
      if map.get(entity.x, entity.y).is_a? Bot
        surronding_bots += 1
      end
    end

    if surronding_bots >= $BOTS_TO_WIN
      true
    else
      false
    end
  end

  # Used when turning the map into a string. Each entity has their own number
  # returns 5
  def to_number
    5
  end
end