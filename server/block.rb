require_relative 'entity.rb'
require_relative 'constants.rb'

class Block < Entity
  def initialize (x, y, is_destroyable)
    super(x, y, 0, $BLOCK_HEALTH, is_destroyable, false)
  end

  def to_number
    3
  end
end