require_relative "settings"

class Player
  def initialize(file_image, x, y)
    @image = Gosu::Image.new(file_image, :tileable => true)
    @pos_x = x
    @pos_y = y
    @moving = false
  end

  def set_moving(move)
    @moving = move
  end

  def move
    if @moving

    end
  end

  def update

  end

  def draw
    @image.draw(@pos_x, @pos_y, 0)
  end
end
