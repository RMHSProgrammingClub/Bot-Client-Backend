require_relative 'block.rb'

class Wall < Block
  def initialize (x, y)
    super(x, y, false)
  end

  def to_number
    4
  end
end