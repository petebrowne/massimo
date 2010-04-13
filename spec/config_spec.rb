require File.expand_path('../spec_helper', __FILE__)

describe Massimo::Config do
  its(:source_path) { should == '.' }
  its(:output_path) { should == './public' }
  
  describe '#initialize' do
    context 'with an options hash' do
      it 'should set the given attributes' do
        configuration = Massimo::Config.new :source_path => 'source/dir'
        configuration.source_path.should == 'source/dir'
      end
    end
    
    context 'with a string' do
      it 'should read a YAML file for configuration' do
        within_construct do |c|
          c.file 'config.yml', "source_path: source/dir\n"
          configuration = Massimo::Config.new 'config.yml'
          configuration.source_path.should == 'source/dir'
        end
      end
    end
  end
end
