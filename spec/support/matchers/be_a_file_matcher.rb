RSpec::Matchers.define :be_a_file do
  match do |path|
    @path = path.to_s
    file? && content_matches?
  end
  
  def with_content(content)
    @content = content
    self
  end

  def file?
    File.file?(@path)
  end

  def content_matches?
    case @content
    when String
      File.read(@path).strip == @content.strip
    when Regexp
      File.read(@path) =~ @content
    else
      true
    end
  end
end
