require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Resource do
  let(:resource) { Massimo::Resource.new 'file.txt' }
  
  describe '#initialize' do
    it 'should require the #source_path to the file' do
      expect { Massimo::Resource.new }.to raise_error
    end
  end
  
  describe '#source_path' do
    context 'when set with a string' do
      it 'should be a Pathname object' do
        within_construct do |c|
          c.file 'file.txt'
          resource.source_path.should be_an_instance_of(Pathname)
        end
      end
    end
  end
  
  describe '#url' do
    it 'should be created from the filename' do
      within_construct do |c|
        c.file 'a_resource_url.erb'
        Massimo::Resource.new('a_resource_url.erb').url.should == '/a-resource-url.erb'
      end
    end
    
    it "should prepend the Resource's url" do
      within_construct do |c|
        c.file 'url.erb'
        Massimo.config.resources_url = '/resources'
        Massimo::Resource.new('url.erb').url.should == '/resources/url.erb'
      end
    end
    
    it 'should replace custom extensions' do
      within_construct do |c|
        c.file 'url.erb'
        resource = Massimo::Resource.new('url.erb')
        mock(resource).extension { '.rss' }
        resource.url.should == '/url.rss'
      end
    end
    
    it 'should drop directory index file names' do
      within_construct do |c|
        c.file 'some/url/index.html'
        Massimo::Resource.new('some/url/index.html').url.should == '/some/url/'
      end
    end
  end
  
  describe '#extension' do
    it 'should be the extension of the file' do
      within_construct do |c|
        c.file 'url.erb'
        Massimo::Resource.new('url.erb').extension.should == '.erb'
      end
    end
  end
  
  describe '#filename' do
    it 'should be the filename of the file' do
      within_construct do |c|
        c.file 'url.erb'
        Massimo::Resource.new('url.erb').filename.should == 'url.erb'
      end
    end
  end
  
  describe '#output_path' do
    it 'should be a Pathname object' do
      within_construct do |c|
        c.file 'file.txt'
        resource.output_path.should be_an_instance_of(Pathname)
      end
    end
    
    it 'should move the #source_path to the sites output dir' do
      within_construct do |c|
        c.file 'file.txt'
        resource.output_path.to_s.should == File.expand_path('public/file.txt')
      end
    end
    
    it 'should re-add directory index file names' do
      within_construct do |c|
        c.file 'some/url/index.html'
        resource = Massimo::Resource.new('some/url/index.html')
        resource.output_path.to_s.should == File.expand_path('public/some/url/index.html')
      end
    end
  end
  
  describe '#content' do
    it "should read the associated file's content" do
      within_construct do |c|
        c.file('file.txt', 'content')
        resource.content.should == 'content'
      end
    end
  end
  
  describe '#render' do
    it "should return the file's content" do
      within_construct do |c|
        c.file('file.txt', 'content')
        resource.render.should == 'content'
      end
    end
  end
  
  describe '#process' do
    it 'should create a file with the rendered content' do
      within_construct do |c|
        c.file('file.txt', 'content')
        resource.process
        File.read('./public/file.txt').should == 'content'
      end
    end
  end
  
  describe '.resource_name' do
    context 'for Resource' do
      it "should be 'resource'" do
        Massimo::Resource.resource_name.should == 'resources'
      end
    end
    
    context 'for Page' do
      it "should be 'page'" do
        Massimo::Page.resource_name.should == 'pages'
      end
    end
    
    context 'for a custom Resource' do
      it 'should be determined based on the class name' do
        NewResource = Class.new(Massimo::Resource)
        NewResource.resource_name.should == 'new_resources'
      end
    end
  end
  
  describe '.path' do
    it 'should get the path from the configuration' do
      Massimo::Site.new :pages_path => 'some/path'
      Massimo::Page.path.should == File.expand_path('some/path')
    end
  end
  
  describe '.url' do
    it 'should get the url from the configuration' do
      Massimo::Site.new :pages_url => '/pages'
      Massimo::Page.url.should == '/pages'
    end
  end
  
  describe '.find' do
    it 'should find resources by their file name' do
      within_construct do |c|
        c.file 'views/partials/post.haml', '%h1 Post'
        Massimo::View.find('partials/post').content.should == '%h1 Post'
      end
    end
  end
end
