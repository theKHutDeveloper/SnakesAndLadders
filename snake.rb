class Snake

  def initialize(file_image, x, y)
    @snake = Gosu::Image.new(file_image, :tileable => true)
    @pos_x = x
    @pos_y = y
  end

  def draw
    @snake.draw(@pos_x, @pos_y, 0)
  end

end
