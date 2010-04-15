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
        resource.source_path.should be_an_instance_of(Pathname)
      end
    end
  end
  
  describe '#url' do
    it 'should be created from the filename' do
      Massimo::Resource.new('a_resource_url.erb').url.should == '/a-resource-url.erb'
    end
    
    it "should prepend the Resource's url" do
      Massimo.config.resources_url = '/resources'
      Massimo::Resource.new('url.erb').url.should == '/resources/url.erb'
    end
    
    it 'should replace custom extensions' do
      resource = Massimo::Resource.new('url.erb')
      mock(resource).extension { '.rss' }
      resource.url.should == '/url.rss'
    end
    
    it 'should drop directory index file names' do
      Massimo::Resource.new('some/url/index.html').url.should == '/some/url/'
    end
  end
  
  describe '#extension' do
    it 'should be the extension of the file' do
      Massimo::Resource.new('url.erb').extension.should == '.erb'
    end
  end
  
  describe '#output_path' do
    it 'should be a Pathname object' do
      resource.output_path.should be_an_instance_of(Pathname)
    end
    
    it 'should move the #source_path to the sites output dir' do
      resource.output_path.to_s.should == File.expand_path('public/file.txt')
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
        class NewResource < Massimo::Resource; end
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
end
