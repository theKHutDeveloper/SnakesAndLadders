class Dice
  def initialize
    @dice = Gosu::Image.new("")
    @pos_x = @pos_y = 0
  end

  def draw
    @dice.draw(@pos_x, @pos_y, 0)

  end
end
