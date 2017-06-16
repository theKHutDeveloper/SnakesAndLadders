require 'gosu'

class Game < Gosu::Window
  def initialize
    super 640, 640
    self.caption = "Snakes & Ladders"
    @board_img = Gosu::Image.new("assets/gameboard_with_nums.png", :tileable => true)
  end

  def update; end

  def draw; end
end

Game.new.show
