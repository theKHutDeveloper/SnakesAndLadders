class Gui

  def initialize(file_image, x, y)
    @image = Gosu::Image.new(file_image, :tileable => true)
    @pos_x = x
    @pos_y = y
    @moving = false
  end

  def is_selected?(mouse_x, mouse_y)
    true if mouse_x >= @pos_x && mouse_x <= (@pos_x + @image.width) &&
      mouse_y >= @pos_y && mouse_y <= (@pos_y + @image.height)
  end

  def draw
    @image.draw(@pos_x, @pos_y, 0)
  end
end
