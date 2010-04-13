require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Site do
  describe '#initialize' do
    context 'with an options hash' do
      it 'configures the site' do
        site = Massimo::Site.new :source_path => 'source/dir'
        site.config.source_path.should == 'source/dir'
      end
    end
    context 'with a string' do
      it 'should read a YAML file for configuration' do
        within_construct do |c|
          c.file 'config.yml', "source_path: source/dir\n"
          site = Massimo::Site.new 'config.yml'
          site.config.source_path.should == 'source/dir'
        end
      end
    end
    
    context 'with a configuration block' do
      it 'configures the site' do
        site = Massimo::Site.new do |config|
          config.source_path = 'source/dir'
        end
        site.config.source_path.should == 'source/dir'
      end
    end
  end
end
