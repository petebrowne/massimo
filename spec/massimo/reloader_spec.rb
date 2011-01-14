require 'spec_helper'

describe Massimo::Reloader do
  def within_load_path
    begin
      dir  = create_construct
      path = dir.expand_path.to_s
      $LOAD_PATH << path
      dir.maybe_change_dir(true) do
        yield dir
      end
    ensure
      $LOAD_PATH.delete(path)
      dir.destroy!
    end
  end
  
  describe '#load' do
    after :each do
      Object.send(:remove_const, :Constant) if Object.const_defined?(:Constant)
    end
    
    it 'stores the loaded constants in a cache' do
      cache = Massimo::Reloader.load do
        module Constant; end
      end
      cache[:constants][0].to_s.should == 'Constant'
    end
    
    it 'stores the loaded feature paths in a cache' do
      within_load_path do |d|
        feature = d.file 'lib/constant.rb', 'module Constant; end'
        cache = Massimo::Reloader.load do
          require 'lib/constant'
        end
        cache[:constants][0].to_s.should == 'Constant'
        cache[:features][0].should == feature.expand_path.to_s
      end
    end
    
    context 'with a cache name' do
      it 'stores a different cache for each given name' do
        default_cache = Massimo::Reloader.load
        cache = Massimo::Reloader.load(:libs) do
          module Constant; end
        end
        default_cache.should_not === cache
      end
    end
  end
end
