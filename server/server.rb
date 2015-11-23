require 'optparse'

require_relative 'game.rb'

# Main
game = Game.new(ARGV[0], ARGV[1])
puts "Server started"

game.start
puts "Match started"

puts "Running turn"
game.run_turn