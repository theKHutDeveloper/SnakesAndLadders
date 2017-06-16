require 'gosu'

class Game < Gosu::Window
  def initialize
    super 640, 640
    self.caption = "Snakes & Ladders"
    @board_img = Gosu::Image.new("assets/gameboard_with_nums.png", :tileable => true)
    set_players
  end

  def update; end

  def draw
    @board_img.draw(0,0,0)
  end

  def set_players
    @total_players = 2
  end
end

Game.new.show
