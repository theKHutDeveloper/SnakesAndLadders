class Dice
  def initialize
    @dice = Gosu::Image.load_tiles('assets/dice.png', 48, 47, {tileable: true})
    @pos_x = 320
    @pos_y = 720
    @dice_value = 1
  end

  def roll_dice
    @dice_value = rand(1..6)
  end

  def draw(frame)
    @dice[frame - 1].draw(@pos_x, @pos_y, 0)
  end
end
