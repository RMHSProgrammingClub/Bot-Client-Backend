require 'fileutils'

task :default => [:build]

task :build do
  FileUtils.rm_f("build/server.jar")
  FileUtils.mkdir_p("build/")
  FileUtils.mkdir_p("build/bin")

  puts "Preparing code"
  ruby "concat.rb"
  FileUtils.cp("release/full.rb", "build/bin/")
  FileUtils.cd("build/")

  puts "Building jar"
  `warble jar`
  FileUtils.mv("build.jar", "server.jar")

  puts "Cleaning up"
  FileUtils.rm_rf("release/")
  FileUtils.rm_rf("build/bin")
end