require 'spec_helper'

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
        with_file 'file.txt' do
          resource.source_path.should be_an_instance_of(Pathname)
        end
      end
    end
  end
  
  describe '#url' do
    it 'should be created from the filename' do
      with_file 'a_resource_url.erb' do
        Massimo::Resource.new('a_resource_url.erb').url.should == '/a-resource-url.erb'
      end
    end
    
    it "should prepend the Resource's url" do
      with_file 'url.erb' do
        Massimo.config.resources_url = '/resources'
        Massimo::Resource.new('url.erb').url.should == '/resources/url.erb'
      end
    end
    
    it 'should replace custom extensions' do
      with_file 'url.erb' do
        resource = Massimo::Resource.new('url.erb')
        stub(resource).extension { '.rss' }
        resource.url.should == '/url.rss'
      end
    end
  end
  
  describe '#extension' do
    it 'should be the extension of the file' do
      with_file 'url.erb' do
        Massimo::Resource.new('url.erb').extension.should == '.erb'
      end
    end
  end
  
  describe '#filename' do
    it 'should be the filename of the file' do
      with_file 'url.erb' do
        Massimo::Resource.new('url.erb').filename.should == 'url.erb'
      end
    end
  end
  
  describe '#output_path' do
    it 'should be a Pathname object' do
      with_file 'file.txt' do
        resource.output_path.should be_an_instance_of(Pathname)
      end
    end
    
    it 'should move the #source_path to the sites output dir' do
      with_file 'file.txt' do
        resource.output_path.to_s.should == File.expand_path('public/file.txt')
      end
    end
    
    context 'with a custom #base_url' do
      it 'should not include the #base_url' do
        Massimo.config.base_url = '/blog'
        with_file 'file.txt' do
          resource.output_path.to_s.should == File.expand_path('public/file.txt')
        end
      end
    end
  end
  
  describe '#content' do
    it "should read the associated file's content" do
      with_file 'file.txt', 'content' do
        resource.content.should == 'content'
      end
    end
  end
  
  describe '#render' do
    it "should return the file's content" do
      with_file 'file.txt', 'content' do
        resource.render.should == 'content'
      end
    end
  end
  
  describe '#process' do
    it 'should create a file with the rendered content' do
      with_file 'file.txt', 'content' do
        resource.process
        File.read('public/file.txt').should == 'content'
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
      with_file 'views/partials/post.haml', '%h1 Post' do
        Massimo::View.find('partials/post').content.should == '%h1 Post'
      end
    end
  end
  
  describe '.all' do
    context 'with no options' do
      it 'should return an array of the resource type' do
        within_construct do |c|
          c.file 'file.txt'
          c.file 'file-2.txt'
          Massimo::Resource.all.map(&:class).should == [ Massimo::Resource, Massimo::Resource ]
        end
      end
      
      it 'should find all the files in the resource path' do
        within_construct do |c|
          c.file 'pages/index.haml'
          c.file 'pages/about/us.haml'
          c.file 'pages/contact/us.erb'
          Massimo::Page.all.map(&:filename).should =~ %w( index.haml us.haml us.erb)
        end
      end
      
      it 'should skip files with prefixed underscores' do
        within_construct do |c|
          c.file 'stylesheets/main.sass'
          c.file 'stylesheets/_base.sass'
          c.file 'stylesheets/_mixins.sass'
          Massimo::Stylesheet.all.map(&:filename).should =~ %w( main.sass )
        end
      end
    end
  end
  
  describe '.processable?' do
    it 'should be true be default' do
      Massimo::Resource.should be_processable
    end
    
    context 'when a process in unprocessable' do
      it 'should be false' do
        class Unprocessable < Massimo::Resource
          unprocessable
        end
        Unprocessable.should_not be_processable
      end
    end
  end
  
  describe '.unprocessable' do
    it 'should overwrite #process to do nothing' do
      class NewResource < Massimo::Resource
        unprocessable
      end
      with_file 'resource.txt' do
        dont_allow(File).open
        NewResource.new('resource.txt').process
      end
    end
  end
end