require_relative 'entity.rb'

class Flag < Entity
  attr_reader :team
  def initialize (x, y, team)
    @team = team

    super(x, y, 0, 0, false, false)
  end

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

  def to_number
    5
  end
end