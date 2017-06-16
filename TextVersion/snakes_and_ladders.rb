require_relative "game_module"

class SnakesAndLadders

#Add functionality to change ladders and snakes to different positions
#snakes can not start < 10 and can not start at 100
#ladders can not start > 90

  def initialize
    @order, @players = [], []

    puts GameModule::PLAY_GAME
    play = gets.chomp
    play == 'y' ? game_setup : puts('Exiting Game')
  end

  def set_players
    loop do
      puts GameModule::SELECT_PLAYER_NUMS
      players = gets.chomp

      if players.to_i.between?(1, 4)
        @total_players = players.to_i
        puts "You have selected to play with #{@total_players} player/s!"
        break
      end
    end
  end

  def name_players
    puts GameModule::CHOOSE_PLAYER_NICKNAMES
    answer = gets.chomp

    if answer == 'y'
      0.upto(@total_players - 1) { | i |
        loop do
          puts "Enter player #{i+1} name"
          name = gets.chomp

          puts "#{name} - correct? [Type 'y' for YES or any other key if incorrect]"
          valid = gets.chomp

          if valid == 'y'
            details = {name: name, position: 0, dice: 0}
            @players.push(details)
            break
          end
        end
      }
    else
      0.upto(@total_players - 1) { | i |
        details = {name: "player#{i+1}", position: 0, dice: 0}
        @players.push(details)
      }
    end
  end

  def set_board
    @board = GameModule::BOARD
    @snakes = GameModule::SNAKES
    @ladders = GameModule::LADDERS
  end

  def single_player
      @players.push({name: "computer", position: 0, dice: 0}) if @total_players == 1
      @total_players += 1
  end

  def get_order_of_play
    puts GameModule::HOW_TO_PLAY_TEXT
    puts GameModule::SET_ORDER_TEXT

    dice_max = @players.collect { |player| player[:dice] }.flatten.max
    max_count = @players.collect{ |player| player[:dice] }.flatten.count(dice_max)

    while max_count > 1
      @players.each do |player|
        if player[:name] == 'computer'
          player[:dice] = roll_dice
          puts "#{player[:name]} rolled a #{player[:dice]}"
        else
          puts "#{player[:name]} press any key to roll the dice"
          action = gets.chomp
          player[:dice] = roll_dice
          puts "#{player[:name]} you rolled a #{player[:dice]}"
        end
      end

      dice_max = @players.collect { |player| player[:dice] }.flatten.max
      max_count = @players.collect{ |player| player[:dice] }.flatten.count(dice_max)
    end

    index = @players.map{ |player| player[:dice]}.flatten.index(dice_max)
    @order.push(index)

    1.upto(@players.size - 1) { | i |
      @order[i-1] == (@players.size - 1) ? @order.push(0) : @order.push(@order[i-1]+1)
    }

    puts "#{@players[@order[0]][:name]} scored the highest and will play first \n"
    clear_dice_values
  end

  def clear_dice_values
    @players.each do | player |
      player[:dice] = 0
    end
  end


  def play_board_game
    quit_game = 0
    until winner? || quit_game == 1

      @order.each do | i |
        loop do
          if @players[i][:name] == 'computer'
            @players[i][:dice] = roll_dice
            puts ""
            print "#{@players[i][:name]} rolled a #{@players[i][:dice]}"
          else
            puts " "
            puts "#{@players[i][:name]}: (press 'q' to quit game or any other key to roll the dice)"

            action = gets.chomp
            if action == 'q'
              quit_game = 1
              puts "Exiting Game"
              break;
            else
              @players[i][:dice] = roll_dice
              print "#{@players[i][:name]} you rolled a #{@players[i][:dice]} "
            end
          end

          score = @players[i][:position] + @players[i][:dice]
          @players[i][:position] = score if score <= GameModule::WINNING_SCORE
          puts " - position is: #{@players[i][:position]}"
          check_if_landed_on_snake_or_ladder(i, @players[i][:position])

          if winner?
            puts "Congratulations #{@players[i][:name]}, you have WON!!!!"
            break
          end

          break if @players[i][:dice] != 6
        end
      end
    end
  #end
  end

  def winner?
    high_score = @players.collect { |player| player[:position]}.flatten.max
    high_score == GameModule::WINNING_SCORE
  end

  def check_if_landed_on_snake_or_ladder(index, score)
    snake = GameModule::SNAKES.keys.find { | i | i == score }

    if !snake.nil?
      down = GameModule::SNAKES[snake]
      puts "Ooops, you landed on a snake...down you go to #{down}"
      @players[index][:position] = down
    else
      ladder = GameModule::LADDERS.keys.find { | i | i == score }
      if !ladder.nil?
        up = GameModule::LADDERS[ladder]
        puts "Great!!!, there's a ladder, let's go up to #{up}"
        @players[index][:position] = up
      end
    end
  end

  def game_setup
    set_players
    name_players
    single_player
    set_board
    get_order_of_play
    play_board_game
  end

  def roll_dice
    rand(1..6)
  end
end

snakes_and_ladders = SnakesAndLadders.new
