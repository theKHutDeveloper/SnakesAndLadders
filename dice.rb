class Dice
  ROLL_TIME = 2000

  attr_accessor :pos_x, :pos_y
  attr_reader :width, :height

  def initialize(x, y)
    @width = 48
    @height = 47
    @dice = Gosu::Image.load_tiles('assets/dice.png', @width, @height, {tileable: true})
    @pos_x = x
    @pos_y = y
    @dice_value = 0
    @start_roll = 1

  end

  def roll_dice
    if @start_roll == 1
      @start_roll = Gosu::milliseconds
    end
  end

  def update
    if @start_roll > 1
      now = Gosu::milliseconds
      if now < (@start_roll + ROLL_TIME)
        @dice_value = rand(1..6)
        now = Gosu::milliseconds
      elsif now > (@start_roll + ROLL_TIME)
        @start_roll = 1
      end
    end
  end

  def reset_dice
    @dice_value = 0
  end

  def dice_value
    @start_roll == 1 ? @dice_value : 0
  end

  def draw
    if @dice_value == 0
      @dice[0].draw(@pos_x, @pos_y, 0)
    else
      @dice[@dice_value - 1].draw(@pos_x, @pos_y, 0)
    end
  end
end
