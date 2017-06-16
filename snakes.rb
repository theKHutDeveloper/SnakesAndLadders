class Snake
  def initialize(file_image)
    @snake = Gosu::Image.new(file_image)
    @pos_x = @pos_y = 0
  end

  def draw
    @snake.draw(@pos_x, @pos_y, 0)
  end
end
