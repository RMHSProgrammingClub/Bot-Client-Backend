require 'fileutils'
require 'rbconfig'

path = File.expand_path(File.dirname(File.dirname(__FILE__))) + "/server/"

dirname = File.dirname("release/")
unless File.directory?("release/")
  FileUtils.mkdir_p("release/")
end

program = ""
files = [path + "constants.rb", path + "entity.rb", path + "bot.rb", path + "team.rb", path + "ai.rb", path + "air.rb", path + "block.rb", path + "wall.rb", path + "connection.rb", path + "flag.rb", path + "game.rb", path + "map.rb", path + "server.rb", path + "game.rb"]

for i in files
  f = File.open(i, "r")

  f.each_line do |line|
    program += line
  end

  f.close

  program += "\n\n"
end

program.gsub!(/^.*require_relative.*$/, "")

out = File.open("release/full.rb", 'w')
out.puts(program)
out.close