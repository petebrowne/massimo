require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Site do
  describe '#initialize' do
    context 'with an options hash' do
      it 'configures the site' do
        site = Massimo::Site.new :source_path => 'source/dir'
        site.config.source_path.should == File.expand_path('source/dir')
      end
    end
    context 'with a string' do
      it 'should read a YAML file for configuration' do
        within_construct do |c|
          c.file 'config.yml', "source_path: source/dir\n"
          site = Massimo::Site.new 'config.yml'
          site.config.source_path.should == File.expand_path('source/dir')
        end
      end
    end
    
    context 'with a configuration block' do
      it 'configures the site' do
        site = Massimo::Site.new do |config|
          config.source_path = 'source/dir'
        end
        site.config.source_path.should == File.expand_path('source/dir')
      end
    end
  end
  
  describe '#resources' do
    it 'should be an array' do
      Massimo::Site.new.resources.should be_an_instance_of(Array)
    end
    
    it 'should include Massimo::Page by default' do
      Massimo::Site.new.resources.should include(Massimo::Page)
    end
  end
  
  describe '#resource' do
    context 'with a Class constant' do
      it "should add a resource to the site's resources" do
        Post = Class.new(Massimo::Resource)
        site = Massimo::Site.new
        site.resource Post
        site.resources.should include(Post)
      end
    end
    
    context 'with a Class body' do
      before do
        @site = Massimo::Site.new
        @site.resource :comment do
          def spam?
            true
          end
        end
      end
      
      it 'should create a class that inherits from Page' do
        Comment.superclass.should == Massimo::Page
      end
      
      it "should add the class to the site's resources" do
        @site.resources.should include(Comment)
      end
      
      it 'should add the methods in the class body' do
        within_construct do |c|
          c.file 'comment.txt'
          Comment.new('comment.txt').should be_spam
        end
      end
    end
  end
end
