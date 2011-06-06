require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)
require "rack/test"
require "construct"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include Construct::Helpers
  config.include Rack::Test::Methods
  config.mock_with :rr
  
  config.before :each do
    stub($stdout).puts
    stub_module("Growl").notify
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
  
  # Creates a blank module with the given name (creating base modules if necessary)
  def blank_module(name)
    name.split("::").inject(Object) do |memo, const|
      if memo.const_defined?(const)
        memo.const_get(const)
      else
        memo.const_set(const, Module.new)
      end
    end
  end
  
  # Creates a blank module wraps it as a mock object in rr
  def mock_module(name)
    mock(blank_module(name))
  end
  
  # Creates a blank module wraps it as a stubbed object in rr
  def stub_module(name)
    stub(blank_module(name))
  end
end