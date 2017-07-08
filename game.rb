require 'gosu'
require_relative 'settings'
require_relative 'player'
require_relative 'dice'
require_relative 'gui'
require_relative 'snake'
require_relative 'ladder'

class Game < Gosu::Window
  SCREENS = [:title, :instructions, :selection, :play_order, :chose_counter, :game, :fin]

  def initialize
    super 640, 800
    self.caption = "Snakes & Ladders"
    @font = Gosu::Font.new(20)
    @dice = Dice.new(300, 300)
    @dice_active = false
    @dice_pressed = false
    @chose_dice = 0
    @current_screen = SCREENS.find_index(:title)
    @buffer = Gosu::TextInput.new
    create_gui_images
    create_snakes
    create_ladders
    create_counters
    create_icons
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
        @dice_pressed = true
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
    elsif id == Gosu::MsLeft && @current_screen == SCREENS.find_index(:play_order)
      if @dice_active
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
            @dice_active = false
            @player_counter = 0
            @current_screen = SCREENS.find_index(:chose_counter)
            set_screen(@current_screen)
          end
        end
      end
    elsif id == Gosu::MsLeft && @current_screen == SCREENS.find_index(:chose_counter)
      if @player_counter < @total_players
        @counters.each_with_index { | counter, i |
          if mouse_x >= counter.pos_x && mouse_x <= counter.pos_x + counter.width &&
            mouse_y >= counter.pos_y && mouse_y <= counter.pos_y + counter.height
            @players[@order[@player_counter]][:counter] = counter
            @players[@order[@player_counter]][:icon] = @temp_icons[i]
            @player_counter += 1 if @player_counter < @total_players
            @temp_icons.delete_at(i)
            @counters.delete(counter)
            break
          end
        }
      else
        if @next_img.is_selected?(mouse_x, mouse_y)
          @players.each_with_index { | player, i |
            player[:counter].pos_x = Settings::COUNTER_STARTING_POS_X[i]
            player[:counter].pos_y = Settings::COUNTER_STARTING_POS_Y[i]
            player[:icon].pos_x = Settings::ICONS_POS_X[i]
            player[:icon].pos_y = Settings::ICONS_POS_Y
          }

          @dice.pos_x = Settings::PLAYER_TEXT_POS_X[@order[0]]
          @dice_active = true
          @next_step = 0
          @order_index = 0
          @dice.reset_dice
          set_markers
          @dest = []
          @current_screen = SCREENS.find_index(:game)
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
          @order =  []
          @order.push(index)
          1.upto(@players.size - 1) { | i |
            @order[i-1] == (@players.size - 1) ? @order.push(0) : @order.push(@order[i-1]+1)
          }
          @chose_dice = 20
        end
      end
    when SCREENS.find_index(:chose_counter)
      if @player_counter < @total_players
        @player_txt = "#{@players[@order[@player_counter]][:name]}, choose a counter to play with"
      end
    when SCREENS.find_index(:game)
      ordered = @order[@order_index]
      @dice.pos_x = Settings::PLAYER_TEXT_POS_X[ordered]
      @dice.pos_y = 720
      @dice.update

      if @dice_pressed
        if @dice.dice_value != 0
          @players[ordered][:dice] = @dice.dice_value
          puts "dice = #{@players[ordered][:dice]}"
          score = @players[ordered][:position] + @players[ordered][:dice]

          if score <= Settings::WINNING_SCORE
            offset_x = @players[ordered][:x]
            offset_y = @players[ordered][:y]
            puts "position = #{@players[ordered][:position]}"
            @players[ordered][:position] = score
            @dest = find_position(@players[ordered][:position], offset_x, offset_y)
            puts @dest
            @players[ordered][:counter].set_destination(find_position(@players[ordered][:position], offset_x, offset_y))
            @dice_active = false
          else
            @order_index += 1
            if @order_index == @total_players
              @order_index = 0
            end
            @dice_active = true
          end

          @dice_pressed = false
        end
      end

      if @next_step == 0
        if !@dest.empty?
          if @players[ordered][:counter].pos_x == @dest[0] && @players[ordered][:counter].pos_y == @dest[1]
            @dest.clear
            if landed_on_snake(ordered, @players[ordered][:position])
              @players[ordered][:counter].set_destination(find_position(Settings::SNAKES[@players[ordered][:position]], @players[ordered][:x], @players[ordered][:y]))
              @players[ordered][:counter].snake_or_ladder = true
              @dest = find_position(Settings::SNAKES[@players[ordered][:position]], @players[ordered][:x], @players[ordered][:y])
              @screen_text = "Ooops, you landed on a snake...down you go to #{Settings::SNAKES[@players[ordered][:position]]}"
              @next_step = 2
            elsif landed_on_ladder(ordered, @players[ordered][:position])
              @players[ordered][:counter].set_destination(find_position(Settings::LADDERS[@players[ordered][:position]], @players[ordered][:x], @players[ordered][:y]))
              @players[ordered][:counter].snake_or_ladder = true
              @dest = find_position(Settings::LADDERS[@players[ordered][:position]], @players[ordered][:x], @players[ordered][:y])
              @screen_text = "Great!!!, there's a ladder, let's go up to #{Settings::LADDERS[@players[ordered][:position]]}"
              @next_step = 2
            else
              @next_step = 1
            end
          end
        end
      end

      if @next_step == 2
        if @players[ordered][:counter].pos_x == @dest[0] && @players[ordered][:counter].pos_y == @dest[1]
          @dest.clear
          @next_step = 1
        end
      end

      if @next_step == 1
        if @players[ordered][:dice] == 6
          if @players[ordered][:name] == "computer"
            @dice.roll_dice
            @dice_pressed = true
            @dice_active = true
          else
            @dice_active = true
            @next_step = 0
          end
        else
          @order_index += 1
          @dice_active = true
          @next_step = 0
        end

        if @order_index == @total_players
          @order_index = 0
        end
      end

      @players.each do |player|
        player[:counter].update

        if !player[:counter].moving
          if player[:revised_position] > 0
            player[:position] = player[:revised_position]
            player[:revised_position] = 0
          end

          if winner?
            puts "Congratulations #{player[:name]}, you have WON!!!!"
            @current_screen = SCREENS.find_index(:fin)
            set_screen(@current_screen)
          end
        end
      end

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
        y = 110
        @players.each_with_index { | player, index |
          if index < @chose_dice && @chose_dice < @total_players
            @font.draw("#{player[:name]} rolled a #{player[:dice]}", 10, y, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
            y +=30
          end
        }
        @font.draw("#{@players[@chose_dice][:name]}, click the dice to roll", 10, y, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      elsif @vs_computer && (@chose_dice > 0 && @chose_dice < 6)
        @font.draw("#{@players[0][:name]} rolled a #{@players[0][:dice]}", 10, 110, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @font.draw("#{@players[1][:name]}, is rolling the dice", 10, 140, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @dice.draw
      elsif @chose_dice >= @total_players
        y = 110
        @players.each do | player |
          @font.draw("#{player[:name]} rolled a #{player[:dice]}", 10, y, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
          y += 30
        end
      end

      if @chose_dice == 10
        @font.draw("At least two players rolled the highest dice score. Press the button to roll again", 10, (110 + (30 * @total_players)), 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @roll_img.draw

      elsif @chose_dice == 20
        @font.draw("#{@players[@order[0]][:name]} scored the highest and will play first", 10, (110 + (30 * @total_players)), 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @next_img.draw
      end
    when SCREENS.find_index(:chose_counter)
      @font.draw("Now each player will take turns to choose a counter to represent them on the gameboard", 10, 20, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      if @player_counter < @total_players
        @font.draw(@player_txt, 10, 70, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
      else
        @font.draw("Ok, now let's play!!!", 10, 70, 0, scale_x = 1, scale_y = 1, Gosu::Color::BLACK)
        @next_img.draw
      end
      x = 50
      @counters.each do |counter|
        counter.pos_x = x
        counter.pos_y = 200
        counter.draw
        x += 70
      end
    when SCREENS.find_index(:game)
      @ladders.each do | ladder |
        ladder.draw
      end

      @snakes.each do | snake |
        snake.draw
      end

      @players.each_with_index { | player, i |
        @font.draw("#{player[:name]}", Settings::PLAYER_TEXT_POS_X[i],Settings::PLAYER_TEXT_POS_Y, 0, scale_x = 1, scale_y = 1, Gosu::Color::WHITE)
        player[:counter].draw
        player[:icon].draw
        @dice.draw
      }

      if @next_step == 2
        @font.draw(@screen_text, 120, 695, 0, scale_x = 1, scale_y = 1, Gosu::Color::YELLOW)
      end
    when SCREENS.find_index(:fin)
    end
  end

  def landed_on_snake(index, score)
    snake = Settings::SNAKES.keys.find { | i | i == score }
    landed = false

    if !snake.nil?
      down = Settings::SNAKES[snake]
      @players[index][:revised_position] = down
      landed = true
    end
    landed
  end

  def landed_on_ladder(index, score)
    ladder = Settings::LADDERS.keys.find { | i | i == score }
    landed = false

    if !ladder.nil?
      up = Settings::LADDERS[ladder]
      @players[index][:revised_position] = up
      landed = true
    end
    landed
  end

  def set_markers
    @players.each_with_index { | player, i |
      player[:x] = Settings::TILE_DEFICIENT_X[i]
      player[:y] = Settings::TILE_DEFICIENT_Y[i]
    }
  end

  def set_players(size)
    @total_players = size
    @total_players == 1 ? @vs_computer = true : @vs_computer = false
    set_default_players
    @question = 1
  end

  def set_default_players
    @players = []
    0.upto(@total_players - 1) { | i |
      details = {name: "player#{i+1}", position: 0, dice: 0, revised_position: 0}
      @players.push(details)
    }

    if @vs_computer
      details = {name: "computer", position: 0, dice: 0, revised_position: 0}
      @players.push(details)
    end
  end

  def set_board
    @board = Settings::BOARD
    @snakes = Settings::SNAKES
    @ladders = Settings::LADDERS
  end

  def needs_cursor?; true; end

  def find_position(position, offset_x, offset_y)
    case position
    when 1..10 then y = Settings::TILE * 9
    when 11..20 then y = Settings::TILE * 8
    when 21..30 then y = Settings::TILE * 7
    when 31..40 then y = Settings::TILE * 6
    when 41..50 then y = Settings::TILE * 5
    when 51..60 then y = Settings::TILE * 4
    when 61..70 then y = Settings::TILE * 3
    when 71..80 then y = Settings::TILE * 2
    when 81..90 then y = Settings::TILE
    when 91..100 then y = 0
    end

    case position
    when 1, 20, 21, 40, 41, 60, 61, 80, 81, 100 then x = 0
    when 2, 19, 22, 39, 42, 59, 62, 79, 82, 99 then x = Settings::TILE
    when 3, 18, 23, 38, 43, 58, 63, 78, 83, 98 then x = Settings::TILE * 2
    when 4, 17, 24, 37, 44, 57, 64, 77, 84, 97 then x = Settings::TILE * 3
    when 5, 16, 25, 36, 45, 56, 65, 76, 85, 96 then x = Settings::TILE * 4
    when 6, 15, 26, 35, 46, 55, 66, 75, 86, 95 then x = Settings::TILE * 5
    when 7, 14, 27, 34, 47, 54, 67, 74, 87, 94 then x = Settings::TILE * 6
    when 8, 13, 28, 33, 48, 53, 68, 73, 88, 93 then x = Settings::TILE * 7
    when 9, 12, 29, 32, 49, 52, 69, 72, 89, 92 then x = Settings::TILE * 8
    when 10, 11, 30, 31, 50, 51, 70, 71, 90, 91 then x = Settings::TILE * 9
    end

    x += offset_x
    y += offset_y

    return [x,y]
  end

  def winner?
    high_score = @players.collect { |player| player[:position]}.flatten.max
    high_score == Settings::WINNING_SCORE
  end

  def create_counters
    @counters = [
      Player.new("assets/player_green.png", 0, Settings::TILE * 9),
      Player.new("assets/player_indigo.png", 10, (Settings::TILE * 9 + 15)),
      Player.new("assets/player_yellow.png", 20, (Settings::TILE * 9 + 30)),
      Player.new("assets/player_violet.png", 30, (Settings::TILE * 9 + 45))
    ]
  end

  def create_icons
    @temp_icons = [
      Player.new("assets/player_green.png", 0, 0),
      Player.new("assets/player_indigo.png", 10, 0),
      Player.new("assets/player_yellow.png", 20, 0),
      Player.new("assets/player_violet.png", 30, 0)
    ]
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
