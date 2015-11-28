require 'optparse'

require_relative 'game.rb'

game = Game.new
puts "Server started"

game.start
puts "Match started"


puts "Running game"
game.run