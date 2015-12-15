require 'optparse'

require_relative 'game.rb'

game = Game.new
puts "Server started"

game.start
puts "Match started"

start_time = Time.now
puts "Running game"
game.run
puts "Game took " + (Time.now - start_time).to_s