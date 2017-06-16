class Ladder
  def initialize(file_image)
    @ladder = Gosu::Image.new(file_image)
    @pos_x = @pos_y = 0
  end

  def draw
    @ladder.draw(@pos_x, @pos_y, 0)
  end
end
