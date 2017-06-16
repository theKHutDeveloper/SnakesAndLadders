class Player
  def initialize(file_image)
    @image = Gosu::Image.new(file_image)
    @pos_x = @pos_y = 0
  end

  def move

  end

  def draw
    @image.draw(@pos_x, @pos_y, 0)
  end
end
