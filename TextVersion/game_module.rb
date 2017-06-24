module GameModule
  ORDER_OF_PLAY_SAME_DICE =
"2 or more players scored the same highest number, so we need to roll the dice again to see who gets to play first"

  PLAY_GAME =
"Play Snakes and Ladders? - ['y' for yes or any other key to exit]"

  HOW_TO_PLAY_TEXT = <<-HEREDOC

Instructions:
To decide the order of play each player should roll one die to see
who gets the highest number. Whoever rolls the highest number gets to
take the first turn. After the first player takes a turn, the person
next in the list takes the next turn and so on.

If two or more people roll the same number, and it is the highest number
rolled, each of those people roll the die an additional time to see who
gets to go first.\n
HEREDOC

  SET_ORDER_TEXT = "Ok, let's see who gets to start first!"


  SELECT_PLAYER_NUMS = "Choose from the number of players below"


  CHOOSE_PLAYER_NICKNAMES = "Do you want to change the names of your players?"

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
end
