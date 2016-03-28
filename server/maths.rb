# http://stackoverflow.com/a/2049593
class TrianglePoint
  attr_reader :x, :y
  
  def initialize(x, y)
    @x, @y = x, y
  end
  
end
  
def sign (p1, p2, p3)
  (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
end

def point_in_triangle(pt, v1, v2, v3)
  b1 = sign(pt, v1, v2) < 0.0
  b2 = sign(pt, v2, v3) < 0.0
  b3 = sign(pt, v3, v1) < 0.0
  (b1 == b2) and (b2 == b3)
end