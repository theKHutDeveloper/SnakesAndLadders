require 'gosu'
require_relative 'settings'
require_relative 'player'
require_relative 'dice'

class Game < Gosu::Window

  SCREENS = [:title, :instructions, :selection, :play_order, :game, :fin]

  def initialize
    super 640, 800
    self.caption = "Snakes & Ladders"
    @font = Gosu::Font.new(20)
    @order, @players = [], []
    @dice = Dice.new()
    @current_screen = SCREENS.find_index(:title)
    set_screen(@current_screen)
  end

  def set_screen(screen)
    case screen
    when SCREENS.find_index(:game)
      @bkg_img = Gosu::Image.new("assets/gameboard_with_nums.png", :tileable => true)
    else
      @bkg_img = Gosu::Image.new("assets/title.png", :tileable => true)
    end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  def update
    case @current_screen
    when SCREENS.find_index(:title)
      if Gosu.button_down? Gosu::KB_SPACE
        @current_screen = SCREENS.find_index(:instructions)
        set_screen(@current_screen)
      end
    when SCREENS.find_index(:instructions)
      if Gosu.button_down? Gosu::KB_SPACE
        @current_screen = SCREENS.find_index(:selection)
        set_screen(@current_screen)
      end
    when SCREENS.find_index(:selection)
      if Gosu.button_down? Gosu::KB_1
        set_players(1)
      elsif Gosu.button_down? Gosu::KB_2
        set_players(2)
      # elsif Gosu.button_down? Gosu::KB_3
      #   set_players(3)
      # elsif Gosu.button_down? Gosu::KB_4
      #   set_players(4)
      end
    when SCREENS.find_index(:play_order)
      if Gosu.button_down? Gosu::KB_SPACE
        @current_screen = SCREENS.find_index(:game)
        set_screen(@current_screen)
      end
    when SCREENS.find_index(:game)
      play_board_game
    when SCREENS.find_index(:fin)

    end
  end

  def draw
    @bkg_img.draw(0,0,0)

    case @current_screen
    when SCREENS.find_index(:title)
      @font.draw(Settings::PLAY_GAME, 10, 10, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
    when SCREENS.find_index(:instructions)
      @font.draw(Settings::HOW_TO_PLAY_1, 10, 10, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(" ", 10, 40, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::HOW_TO_PLAY_2, 10, 70, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::HOW_TO_PLAY_3, 10, 100, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::HOW_TO_PLAY_4, 10, 130, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(" ", 10, 170, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::HOW_TO_PLAY_5, 10, 200, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::HOW_TO_PLAY_6, 10, 230, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::HOW_TO_PLAY_7, 10, 260, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw("", 10, 290, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::HOW_TO_PLAY_8, 10, 320, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::SPACEBAR, 10, 370, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
    when SCREENS.find_index(:selection)
      @font.draw(Settings::SELECT_PLAYER_NUMS, 10, 70, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::SELECT_PLAYER_NUMS2, 10, 100, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
    when SCREENS.find_index(:play_order)
      @font.draw("You have selected to play with #{@total_players} player/s!", 10, 10, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK) if !@total_players.nil?
      @font.draw(Settings::SPACEBAR, 10, 50, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
    when SCREENS.find_index(:game)
      @players.each do | player |
        player[:counter].draw
        @dice.draw(player[:dice])
      end

    when SCREENS.find_index(:fin)

    end
  end

  def set_players(size)
    @total_players = size
    0.upto(@total_players - 1) { | i |
      details = {name: "player#{i+1}", position: 0, dice: 0, counter: counters[i]}
      @players.push(details)
      @order.push(i)
    }

    @current_screen = SCREENS.find_index(:play_order)
    set_screen(@current_screen)
  end

  def counters
    imgs = [
      Player.new("assets/player_green.png", 0, Settings::TILE * 9),
      Player.new("assets/player_indigo.png", 10, (Settings::TILE * 9 + 20))
    ]
    imgs
  end

  def set_board
    @board = Settings::BOARD
    @snakes = Settings::SNAKES
    @ladders = Settings::LADDERS
  end

  def winner?
    high_score = @players.collect { |player| player[:position]}.flatten.max
    high_score == Settings::WINNING_SCORE
  end

  def check_if_landed_on_snake_or_ladder(index, score)
    snake = Settings::SNAKES.keys.find { | i | i == score }

    if !snake.nil?
      down = Settings::SNAKES[snake]
      puts "Ooops, you landed on a snake...down you go to #{down}"
      @players[index][:position] = down
    else
      ladder = Settings::LADDERS.keys.find { | i | i == score }
      if !ladder.nil?
        up = Settings::LADDERS[ladder]
        puts "Great!!!, there's a ladder, let's go up to #{up}"
        @players[index][:position] = up
      end
    end
  end

  def play_board_game
    quit_game = 0
    until winner? || quit_game == 1

      @order.each do | i |
        loop do
          @players[i][:dice] = @dice.roll_dice
          puts "#{@players[i][:name]} rolled a #{@players[i][:dice]}"
          score = @players[i][:position] + @players[i][:dice]

          @players[i][:position] = score if score <= Settings::WINNING_SCORE
          puts "You're now at position #{@players[i][:position]}"
          check_if_landed_on_snake_or_ladder(i, @players[i][:position])

          break if @players[i][:dice] != 6
        end

        if winner?
          puts "Congratulations #{@players[i][:name]}, you have WON!!!!"
          break
        end
      end
    end
  end


end

Game.new.show
