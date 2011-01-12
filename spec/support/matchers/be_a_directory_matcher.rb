RSpec::Matchers.define :be_a_directory do
  match do |path|
    File.directory?(path.to_s)
  end
end
