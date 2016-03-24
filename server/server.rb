require 'optparse'

require_relative 'game.rb'

OptionParser.new do |opts|
  opts.banner = 'Usage: example.rb [options]'

  opts.on('-t number', '--max-turns number') do |number|
    $MAX_TURNS = number.to_i
  end
end.parse!

game = Game.new
puts 'Server started'

game.start
puts 'Match started'

start_time = Time.now
puts 'Running game'
game.run
puts 'Game took ' + (Time.now - start_time).to_s