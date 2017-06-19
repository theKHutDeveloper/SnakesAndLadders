#Module
module Settings
  TILE = 64

  BOARD = (1..100).to_a

  SNAKES = {
    17 => 7, 54 => 34, 62 => 18, 64 => 60, 87 => 24, 93 => 63,
    95 => 75, 99 => 78
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
end
