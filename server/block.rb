require_relative 'constants.rb'

class Block
  attr_reader :x, :y, :health, :is_breakable

  def initialize (x, y, is_breakable)
    @x = x
    @y = y
    @is_breakable = is_breakable
    @health = $BLOCK_HEALTH
  end

  def hit
    if @is_breakable
      @health -= $BLOCK_HIT_LOSS
    end
  end
end