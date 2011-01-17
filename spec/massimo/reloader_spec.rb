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
  
  after :each do
    Object.send(:remove_const, :Constant) if Object.const_defined?(:Constant)
  end
  
  describe '.load' do
    it 'stores the loaded constants in a cache' do
      cache = Massimo::Reloader.load do
        module Constant; end
      end
      cache[:constants].map(&:to_s).should include('Constant')
    end
    
    it 'stores the loaded feature paths in a cache' do
      within_load_path do |d|
        feature = d.file('lib/constant.rb', 'module Constant; end').expand_path.to_s
        cache = Massimo::Reloader.load do
          require 'lib/constant'
        end
        cache[:constants].map(&:to_s).should include('Constant')
        cache[:features].should include(feature)
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
  
  describe '.unload' do
    context 'with a constant defined in .load' do
      before do
        Massimo::Reloader.load do
          module Constant; end
        end
      end
      
      it 'undefines the constant' do
        Massimo::Reloader.unload
        defined?(Constant).should be_false
      end
      
      it 'removes the constant from the cache' do
        cache = Massimo::Reloader.unload
        cache[:constants].map(&:to_s).should_not include('Constant')
      end
    end
    
    context 'with a required feature' do
      it 'removes the loaded feature' do
        within_load_path do |d|
          feature = d.file('lib/constant.rb', 'module Constant; end').expand_path.to_s
          Massimo::Reloader.load { require 'lib/constant' }
          $LOADED_FEATURES.should include(feature)
          Massimo::Reloader.unload
          $LOADED_FEATURES.should_not include(feature)
        end
      end
      
      it 'removes the feature from the cache' do
        within_load_path do |d|
          feature = d.file('lib/constant.rb', 'module Constant; end').expand_path.to_s
          Massimo::Reloader.load { require 'lib/constant' }
          cache = Massimo::Reloader.unload
          cache[:features].should_not include(feature)
        end
      end
    end
    
    context 'with a cache name' do
      it 'removes the constants for that cache' do
        Massimo::Reloader.load do
          module Constant; end
        end
        Massimo::Reloader.load(:libs) do
          module AnotherConstant; end
        end
        Massimo::Reloader.unload(:libs)
        defined?(Constant).should be_true
        defined?(AnotherConstant).should be_false
      end
    end
  end
  
  describe '.reload' do
    context 'with a previously defined constant' do
      it 'removes the constant' do
        Massimo::Reloader.reload do
          module Constant; end
        end
        Massimo::Reloader.reload
        defined?(Constant).should be_false
      end
      
      it 'defines new constants' do
        Massimo::Reloader.reload
        Massimo::Reloader.reload do
          module Constant; end
        end
        defined?(Constant).should be_true
      end
    end
  end
end
