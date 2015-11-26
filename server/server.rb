require 'optparse'

require_relative 'game.rb'

game = Game.new
puts "Server started"

game.start
puts "Match started"

i = 0
while i < 10
  puts "Running turn " + i.to_s
  game.run_turn
end