require 'optparse'

require_relative 'game.rb'

# Main
game = Game.new(ARGV[0], ARGV[1])
puts "Server started"

game.start
puts "Match started"

i = 0
while i < 10
  puts "Running turn " + i.to_s
  game.run_turn
end