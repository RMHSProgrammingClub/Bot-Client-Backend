class Block
  attr_reader :x, :y, :health, :is_breakable
  def initialize (x, y, is_breakable)
    @x = x
    @y = y
    @is_breakable = is_breakable
    @health = 100
  end


end