require_relative 'block.rb'

class Wall < Block
  def initialize (x, y)
    super(x, y, false)
  end
end