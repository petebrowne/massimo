lib = File.expand_path('../../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rubygems'
require 'rspec'
require 'rr'
require 'construct'
require 'rack/test'
require 'unindent'
require 'sass'
require 'less'
require 'coffee-script'
require 'sprockets'
require 'jsmin'
require 'packr'
require 'yui/compressor'
require 'closure-compiler'
require 'growl'
require 'massimo'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include Construct::Helpers
  config.include Rack::Test::Methods
  config.mock_with :rr
  
  config.before :each do
    stub($stdout).puts
    stub(Growl).notify
  end
  
  config.after :each do
    Massimo.site = nil
  end
  
  # Builds a construct with a single file in it.
  def with_file(filename, content = nil)
    within_construct do |construct|
      construct.file filename, content
      yield
    end
  end
  
  # Captures the given stream and returns it:
  #
  #   stream = capture(:stdout) { puts "Cool" }
  #   stream # => "Cool\n"
  #
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  alias :silence :capture
end