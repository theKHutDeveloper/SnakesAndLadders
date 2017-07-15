#Module
module Settings
  TILE = 64

  PLAYER_TEXT_POS_X = [90, 220, 350, 480]
  PLAYER_TEXT_POS_Y = 660

  TILE_DEFICIENT_X  = [0, 10, 20, 30]
  TILE_DEFICIENT_Y  = [0, 15, 30, 45]

  ICONS_POS_X = [50, 180, 310, 440]
  ICONS_POS_Y = 650

  COUNTER_STARTING_POS_X = [0, 10, 20, 30]

  COUNTER_STARTING_POS_Y = [(TILE * 9), (TILE * 9) + 15, (TILE * 9) + 30, (TILE * 9) + 45]

  BOARD = (1..100).to_a

  SNAKES = {
    17 => 7, 54 => 34, 62 => 18, 64 => 60, 87 => 24, 93 => 50,
    96 => 75, 99 => 78
  }

  LADDERS = {
    4 => 14, 9 => 31, 20 => 38, 28 => 84, 40 => 59, 63 => 81,
    71 => 91
  }

  WINNING_SCORE = 100

  PLAY_GAME = "Play Snakes and Ladders? - [spacebar to continue OR 'esc' to exit]"

  HOW_TO_PLAY_1 = "HOW TO PLAY:"
  HOW_TO_PLAY_2 = "Each player puts their counter on tile marked '1'. Each players takes"
  HOW_TO_PLAY_3 = "turns to roll the dice to move their counter forward the number of"
  HOW_TO_PLAY_4 = "spaces shown on the dice."
  HOW_TO_PLAY_5 = "If your counter lands at the bottom of a ladder, you move up to the"
  HOW_TO_PLAY_6 = "top of the ladder. If your counter lands on the head of a snake, you"
  HOW_TO_PLAY_7 = "will slide down to the bottom of the snake."
  HOW_TO_PLAY_8 = "The first player to get to 100 is the winner."

  SPACEBAR = "Press spacebar to continue"

  SELECT_PLAYER_NUMS = "Select number of players between 1 and 2" #4
  SELECT_PLAYER_NUMS2 = "[1 player: plays against computer]"

  CHOOSE_PLAYER_NICKNAMES = "Do you want to give your player/s nicknames?"

  SET_ORDER_TEXT = "Ok, let's see who gets to start first!"

end
