require 'gosu'
require_relative 'settings'
require_relative 'player'
require_relative 'dice'
require_relative 'gui'
require_relative 'snake'
require_relative 'ladder'

class Game < Gosu::Window

  SCREENS = [:title, :instructions, :selection, :play_order, :game, :fin]

  def initialize
    super 640, 800
    self.caption = "Snakes & Ladders"
    @font = Gosu::Font.new(20)
    @order, @players = [], []
    @dice = Dice.new(300, 300)
    @dice_active = false
    @current_screen = SCREENS.find_index(:title)
    @buffer = Gosu::TextInput.new
    @chose_dice = 0
    @dice_pressed = false
    create_gui_images
    create_snakes
    create_ladders
    set_screen(@current_screen)
  end

  def set_screen(screen)
    case screen
    when SCREENS.find_index(:game)
      @bkg_img = Gosu::Image.new("assets/gameboard_with_nums.png", :tileable => true)
    else
      @bkg_img = Gosu::Image.new("assets/bg.png", :tileable => true)
    end
  end

  def button_up(id)
    if id == Gosu::KB_RETURN
      if @current_screen == SCREENS.find_index(:selection) && @question == 2
        @buffer.text = ""
        @player_index += 1

        if @player_index >= @total_players
          @question = 3
          self.text_input = nil
        end
      end
    end
  end

  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    elsif id == Gosu::MsLeft && @current_screen == SCREENS.find_index(:game) && @dice_active
      if mouse_x >= @dice.pos_x && mouse_x <= (@dice.pos_x + @dice.width) &&
        mouse_y >= @dice.pos_y && mouse_y <= (@dice.pos_y + @dice.height)
        @dice.roll_dice
      end
    elsif id == Gosu::MsLeft && @current_screen == SCREENS.find_index(:title)
       if @info_img.is_selected?(mouse_x, mouse_y)
        @current_screen = SCREENS.find_index(:instructions)
        set_screen(@current_screen)
      elsif @next_img.is_selected?(mouse_x, mouse_y)
        @current_screen = SCREENS.find_index(:selection)
        set_screen(@current_screen)
        @question = 0
      end
    elsif id == Gosu::MsLeft && @current_screen == SCREENS.find_index(:instructions)
      if @next_img.is_selected?(mouse_x, mouse_y)
        @current_screen = SCREENS.find_index(:selection)
        set_screen(@current_screen)
        @question = 0
      end
    elsif id == Gosu::MsLeft && @current_screen == SCREENS.find_index(:play_order) && @dice_active
      if mouse_x >= @dice.pos_x && mouse_x <= (@dice.pos_x + @dice.width) &&
        mouse_y >= @dice.pos_x && mouse_y <= (@dice.pos_y + @dice.height)

        if @chose_dice <= (@total_players-1)
          @dice.roll_dice
          @dice_pressed = true
        end
      end

      if @chose_dice == 10
        if @roll_img.is_selected?(mouse_x, mouse_y)
          @chose_dice = 0
        end
      end

      if @chose_dice == 20
        if @next_img.is_selected?(mouse_x, mouse_y)
          @current_screen = SCREENS.find_index(:game)
          set_screen(@current_screen)
        end
      end
    elsif id == Gosu::MsLeft && @current_screen == SCREENS.find_index(:selection)
      if @question == 0
        @chose_players_number.each do |item|
          if item[:img].is_selected?(mouse_x, mouse_y)
            set_players(item[:value])
            break
          end

        end
      elsif @question == 1
        if @yes_img.is_selected?(mouse_x, mouse_y)
          self.text_input = @buffer
          @question = 2
          @player_index = 0
        elsif @no_img.is_selected?(mouse_x, mouse_y)
          if @vs_computer
            @total_players = @total_players + 1
          end
          @current_screen = SCREENS.find_index(:play_order)
          set_screen(@current_screen)
        end
      elsif @question == 3
        if @next_img.is_selected?(mouse_x, mouse_y)
          if @vs_computer
            @total_players = @total_players + 1
          end
          @current_screen = SCREENS.find_index(:play_order)
          set_screen(@current_screen)

        end
      end

    else
      super
    end
  end

  def update
    case @current_screen
    when SCREENS.find_index(:selection)
      if @question == 2
        if Gosu.button_down? Gosu::KB_RETURN
          if @player_index < @total_players
            @players[@player_index][:name] = @buffer.text
          end
        end
      end
    when SCREENS.find_index(:play_order)
      @dice_active = true
      @dice.update
      if @dice_pressed
        if @dice.dice_value != 0
          #puts "Choose dice = #{@chose_dice} & Dice value = #{@dice.dice_value}"
          @players[@chose_dice][:dice] = @dice.dice_value
          if @chose_dice < (@total_players)
            @chose_dice += 1
          end
          @dice_pressed = false
        end
      end

      if @vs_computer && @chose_dice == 5
        if @dice.dice_value != 0
          @players[1][:dice] = @dice.dice_value
          @chose_dice = 2
        end
      end

      if @vs_computer && @chose_dice == 1
        @dice.roll_dice
        @chose_dice = 5
      end

      if @chose_dice == @total_players
        dice_max = @players.collect { |player| player[:dice] }.flatten.max
        max_count = @players.collect{ |player| player[:dice] }.flatten.count(dice_max)

        if max_count > 1
          @chose_dice = 10
        else
          index = @players.map{ |player| player[:dice]}.flatten.index(dice_max)
          @order.push(index)
          1.upto(@players.size - 1) { | i |
            @order[i-1] == (@players.size - 1) ? @order.push(0) : @order.push(@order[i-1]+1)
          }
          #puts "Orders = #{@order}, dice max = #{dice_max}"
          @chose_dice = 20
        end
      end

    when SCREENS.find_index(:game)
      play_board_game
      @dice.pos_x = 20
      @dice.pos_y = 720
      @dice.update
    when SCREENS.find_index(:fin)
    end
  end

  def draw
    @bkg_img.draw(0,0,0)

    case @current_screen
    when SCREENS.find_index(:title)
      @font.draw(Settings::PLAY_GAME, 10, 10, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @next_img.draw
      @info_img.draw
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
      @next_img.draw
    when SCREENS.find_index(:selection)
      @font.draw(Settings::SELECT_PLAYER_NUMS, 10, 70, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @font.draw(Settings::SELECT_PLAYER_NUMS2, 10, 100, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      @chose_players_number.each do |item|
        item[:img].draw
      end

      if @question == 1
        @font.draw(Settings::CHOOSE_PLAYER_NICKNAMES, 10, 270, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @yes_img.draw
        @no_img.draw
      end

      if @question == 2
        if @player_index < @total_players
          @font.draw("Enter name for #{@players[@player_index][:name]}: #{@buffer.text}", 10, 390, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        end
      end

      if @question == 3
        @font.draw("Great, your players are:", 10, 390, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @next_img.draw
        y = 420
        @players.each do |player|
          @font.draw("#{player[:name]}", 10, y, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
          y += 30
        end
      end
    when SCREENS.find_index(:play_order)
      if @vs_computer
        @font.draw("You have selected to play against the computer", 10, 10, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK) if !@total_players.nil?
      else
        @font.draw("You have selected to play with #{@total_players} player/s!", 10, 10, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK) if !@total_players.nil?
      end
      @font.draw(Settings::SET_ORDER_TEXT, 10, 50, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)

      if (@chose_dice < @total_players && !@vs_computer ) || (@vs_computer && @chose_dice == 0)
        @dice.draw
        @font.draw("#{@players[@chose_dice][:name]}, click the dice to roll", 10, 110, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      elsif @vs_computer && (@chose_dice > 0 && @chose_dice < 6)
        @font.draw("#{@players[1][:name]}, is rolling the dice", 10, 110, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      elsif @chose_dice >= @total_players
        y = 110
        @players.each do | player |
          @font.draw("#{player[:name]} rolled a #{player[:dice]}", 10, y, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
          y += 30
        end
      end

      if @chose_dice == 10
        @font.draw("At least two players rolled the highest dice score. Press the button to roll again", 10, 200, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @roll_img.draw

      elsif @chose_dice == 20
        @font.draw("#{@players[@order[0]][:name]} scored the highest and will play first", 10, 200, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @next_img.draw
      end
    when SCREENS.find_index(:game)
      @ladders.each do | ladder |
        ladder.draw
      end

      @snakes.each do | snake |
        snake.draw
      end

      x = 100
      @players.each do | player |
        @font.draw("#{player[:name]}", x, 660, 0, scale_x = 1, scale_y = 1, Gosu::Color::WHITE)
        x+= 260
        player[:counter].draw
        @dice.draw
      end
    when SCREENS.find_index(:fin)

    end
  end


  def set_players(size)
    @total_players = size
    @total_players == 1 ? @vs_computer = true : @vs_computer = false
    set_default_players
    @question = 1
  end

  def set_default_players
    0.upto(@total_players - 1) { | i |
      details = {name: "player#{i+1}", position: 0, dice: 0, counter: counters[i]}
      @players.push(details)
    }

    if @vs_computer
      details = {name: "computer", position: 0, dice: 0, counter: counters[1]}
      @players.push(details)
    end
  end


  def set_board
    @board = Settings::BOARD
    @snakes = Settings::SNAKES
    @ladders = Settings::LADDERS
  end

  # def winner?
  #   high_score = @players.collect { |player| player[:position]}.flatten.max
  #   high_score == Settings::WINNING_SCORE
  # end
  #
  # def check_if_landed_on_snake_or_ladder(index, score)
  #   snake = Settings::SNAKES.keys.find { | i | i == score }
  #
  #   if !snake.nil?
  #     down = Settings::SNAKES[snake]
  #     puts "Ooops, you landed on a snake...down you go to #{down}"
  #     @players[index][:position] = down
  #   else
  #     ladder = Settings::LADDERS.keys.find { | i | i == score }
  #     if !ladder.nil?
  #       up = Settings::LADDERS[ladder]
  #       puts "Great!!!, there's a ladder, let's go up to #{up}"
  #       @players[index][:position] = up
  #     end
  #   end
  # end

  def needs_cursor?; true; end

  def play_board_game
    @dice_active = true
    # quit_game = 0
    # until winner? || quit_game == 1
    #
    #   @order.each do | i |
    #     loop do
    #       #@players[i][:dice] = @dice.roll_dice
    #       puts "#{@players[i][:name]} rolled a #{@players[i][:dice]}"
    #       score = @players[i][:position] + @players[i][:dice]
    #
    #       @players[i][:position] = score if score <= Settings::WINNING_SCORE
    #       puts "You're now at position #{@players[i][:position]}"
    #       check_if_landed_on_snake_or_ladder(i, @players[i][:position])
    #
    #       break if @players[i][:dice] != 6
    #     end
    #
    #     if winner?
    #       puts "Congratulations #{@players[i][:name]}, you have WON!!!!"
    #       break
    #     end
    #   end
    # end
  end

  def counters
    imgs = [
      Player.new("assets/player_green.png", 0, Settings::TILE * 9),
      Player.new("assets/player_indigo.png", 10, (Settings::TILE * 9 + 15)),
      Player.new("assets/player_yellow.png", 20, (Settings::TILE * 9 + 30)),
      Player.new("assets/player_violet.png", 30, (Settings::TILE * 9 + 45))
    ]
    imgs
  end

  def create_gui_images
    @info_img = Gui.new("assets/info.png", 20, 700)
    @next_img = Gui.new("assets/next.png", 500, 680)
    @yes_img = Gui.new("assets/yes.png", 200, 310)
    @no_img = Gui.new("assets/no.png", 300, 310)
    @roll_img = Gui.new("assets/button.png", 300, 300)

    @chose_players_number = [
      {img: Gui.new("assets/one.png", 100, 140), value: 1},
      {img: Gui.new("assets/two.png", 200, 140), value: 2},
      {img: Gui.new("assets/three.png", 300, 140), value: 3},
      {img: Gui.new("assets/four.png", 400, 140), value: 4}
    ]
  end

  def create_snakes
    @snakes = []
    @snakes.push(Snake.new("assets/snake_17_to_7.png", 201, 460))
    @snakes.push(Snake.new("assets/snake_54_to_34.png", 387, 259))
    @snakes.push(Snake.new("assets/snake_62_to_18.png", 25, 201))
    @snakes.push(Snake.new("assets/snake_64_to_60.png", 18, 210))
    @snakes.push(Snake.new("assets/snake_87_to_24.png", 194,64))
    @snakes.push(Snake.new("assets/snake_93_to_50.png", 450, 8))
    @snakes.push(Snake.new("assets/snake_96_to_75.png", 272, 9))
    @snakes.push(Snake.new("assets/snake_99_to_78.png", 80, 5))
  end

  def create_ladders
    @ladders = []
    @ladders.push(Ladder.new("assets/ladder_4_to_14.png", 220, 520))
    @ladders.push(Ladder.new("assets/ladder_9_to_31.png", 524, 404))
    @ladders.push(Ladder.new("assets/ladder_20_to_38.png", 17, 395))
    @ladders.push(Ladder.new("assets/ladder_28_to_84.png", 211, 65))
    @ladders.push(Ladder.new("assets/ladder_40_to_59.png", 21, 273))
    @ladders.push(Ladder.new("assets/ladder_63_to_81.png", 18, 81))
    @ladders.push(Ladder.new("assets/ladder_71_to_91.png", 588, 17))
  end
end

Game.new.show
