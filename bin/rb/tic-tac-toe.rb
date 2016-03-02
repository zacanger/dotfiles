#!/usr/bin/env ruby

class Game
	attr_accessor :board
	def initialize
		@board = create_board(3,3)
	end

	def create_board(row, col)
		board = Array.new(row)
		board.map! do |each_row|
			each_row = Array.new(col)
		end
		board
	end

	def are_there_remaining_spots?
		board.each do |each_row|
			return true if each_row.include?(nil)
		end
		false
	end

	def is_there_a_winner?
		# If winning condition is met, declare the winner (return yes)
		cols = create_columns(board)
		diag1 = [board[0][0], board[1][1], board[2][2]]
		diag2 = [board[0][2], board[1][1], board[2][0]]

		# Test
		# p "This is row1: #{board[0]}"
		# p "This is row2: #{board[1]}"
		# p "This is row3: #{board[2]}"
		# p "This is col1: #{cols[0]}"
		# p "This is col2: #{cols[1]}"
		# p "This is col3: #{cols[2]}"
		# p "This is top-left to bottom-right diagonal: #{diag1}"
		# p "This is bottom-left to top-right: #{diag2}"

		# Check if the rows in board are ok
		return "yes" if is_winning_condition_met?(board[0]) || is_winning_condition_met?(board[1]) || is_winning_condition_met?(board[2])

		# Check if the columns in board are ok
		return "yes" if is_winning_condition_met?(cols[0]) || is_winning_condition_met?(cols[1]) || is_winning_condition_met?(cols[2])

		# Check if the diagonals in board are ok
		return "yes" if is_winning_condition_met?(diag1) || is_winning_condition_met?(diag2)

		# If winning condition is not met and there are no remaining spaces, then declare a draw (return draw)
		return "draw" unless are_there_remaining_spots?

		# If winning condition is not met and there are remaining spaces, then game continues (return no)
		return "no"
	end

	def create_columns(board)
		col1 = []
		col2 = []
		col3 = []
		0.upto(2) do |i|
			col1 << board[i][0]
			col2 << board[i][1]
			col3 << board[i][2]
		end
		return col1, col2, col3
	end

	def is_winning_condition_met?(array)
		return true if (array == [:x, :x, :x] || array == [:o, :o, :o])
		return false
	end
end

class Player
	attr_accessor :x_or_o, :name

	def initialize(name, symbol)
		@name = name
		@x_or_o = symbol
	end

	def place_on_board(board, row, col, symbol)
		if board[row - 1][col - 1].nil?
			board[row - 1][col - 1] = symbol
			return true
		else
			return false
		end
	end
end

puts "Let's play a game of tic-tac-toe!"
puts "Player 1, what's your name?"
name1 = gets.chomp
puts "Hi, #{name1}! Choose either X or O."
symbol1 = gets.chomp.downcase
puts "Player 2, what's your name?"
name2 = gets.chomp
if symbol1 == "x"
  symbol2 = "o"
else
	symbol2 = "x"
end
puts "Hi, #{name2}! Since #{name1} choose #{symbol1}, you're going to be #{symbol2}."

# Set up players and game
player1 = Player.new(name1, symbol1.to_sym)
player2 = Player.new(name2, symbol2.to_sym)
player_array = [player1, player2]
game = Game.new

puts "The game of tic-tac-toe consists of a 3 x 3 board."
puts "If you want to place your symbol in the top-left position of the board, you can specify the row to be 1 and the column to be 1."
puts "If you want to place your symbol in the middle position of the board, you can specify the row to be 2 and the column to be 2."
puts "And if you want to place your symbol in the bottom-right position of the board, you can specify the row to be 3 and the column to be 3."

loop do
	player_array.each do |player|
		loop do
			puts "#{player.name}, what row do you want to enter your symbol #{player.x_or_o}?"
			row = gets.chomp.to_i
			puts "#{player.name}, what column do you want to enter your symbol #{player.x_or_o}?"
			col = gets.chomp.to_i
			break if player.place_on_board(game.board, row, col, player.x_or_o)
			puts "Sorry, you can't place your symbol there since it's already been placed. Try again."
		end

		case game.is_there_a_winner?
		when "yes"
			abort "Congrats #{player.name}, you won!"
		when "draw"
			abort "The game ends in a draw."
		else
			puts "The game keeps on going."
		end
	end
	puts "Here's the game board so far:"
	p game.board
end

