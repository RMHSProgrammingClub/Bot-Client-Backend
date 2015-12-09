require_relative 'constants.rb'

class Entity
  attr_reader :x, :y, :angle, :health, :is_destroyable, :is_destroyed, :is_ghost

  def initialize (x, y, angle, health, is_destroyable, is_ghost)
    @x = x
    @y = y
    @angle = angle
    @health = health
    @is_destroyable = is_destroyable
    @is_destroyed = false
    @is_ghost = is_ghost
  end

  def hit
    if @is_destroyable
      @health -= $BLOCK_HIT_LOSS

      if @health <= 0
        @is_destroyed = true
        @is_ghost = true
      end
    end
  end

  def update (map)

  end

  def to_number
    0
  end
end