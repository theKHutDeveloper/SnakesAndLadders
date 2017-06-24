class Ladder
  def initialize(file_image, x, y)
    @ladder = Gosu::Image.new(file_image, :tileable => true)
    @pos_x = x
    @pos_y = y
  end


  def draw
    @ladder.draw(@pos_x, @pos_y, 0)
  end
end
