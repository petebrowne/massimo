require "rubygems"
require "rake"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name        = "massimo"
    gem.summary     = %{Massimo is a static website builder.}
    gem.description = %{Massimo builds HTML, Javascript, and CSS Files from your source.}
    gem.email       = "peter@peterbrowne.net"
    gem.homepage    = "http://github.com/peterbrowne/massimo"
    gem.authors     = [ "Peter Browne" ]
    gem.add_development_dependency "shoulda",           ">= 2.10.2"
    gem.add_development_dependency "yard",              ">= 0.2.3.5"
    gem.add_dependency             "activesupport",     ">= 2.3.4"
    gem.add_dependency             "directory_watcher", ">= 1.3.1"
    gem.add_dependency             "sprockets",         ">= 1.0.2"
    gem.add_dependency             "jsmin",             ">= 1.0.1"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/**/test_*.rb"
  test.verbose = true
end

begin
  require "rcov/rcovtask"
  Rcov::RcovTask.new do |test|
    test.libs << "test"
    test.pattern = "test/**/test_*.rb"
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r massimo.rb"
end

begin
  require "yard"
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
