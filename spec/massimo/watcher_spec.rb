require 'spec_helper'

describe Massimo::Watcher do
  let(:site)    { Massimo::Site.new(:lib_path => 'libs') }
  let(:watcher) { Massimo::Watcher.new(site) }
  
  def with_files(check_once = true)
    within_construct do |construct|
      construct.file 'pages/index.haml'
      watcher.changed? if check_once
      yield construct
    end
  end
  
  describe '#changed?' do
    it 'returns false' do
      watcher.should_not be_changed
    end
    
    context 'when a file is added' do
      it 'returns true' do
        with_files(false) do |c|
          watcher.should be_changed
        end
      end
    
      context 'then checked without updates' do
        it 'returns false' do
          with_files do |c|
            watcher.should_not be_changed
          end
        end
      end
    end
  
    context 'when a file is removed' do
      it 'returns true' do
        with_files do |c|
          File.delete 'pages/index.haml'
          watcher.should be_changed
        end
      end
    end
  
    context 'when a file is updated' do
      it 'returns true' do
        with_files do |c|
          sleep 1
          File.open('pages/index.haml', 'w+') { |file| file.write('change') }
          watcher.should be_changed
        end
      end
    end
  end
  
  describe '#config_changed?' do
    it 'returns false' do
      watcher.should_not be_config_changed
    end
    
    context 'when a file is updated' do
      it 'returns false' do
        with_files do |c|
          sleep 1
          c.file 'pages/index.haml'
          watcher.should_not be_config_changed
        end
      end
    end
    
    context 'when the config file is updated' do
      it 'returns true' do
        within_construct do |c|
          c.file 'config.rb'
          watcher.config_changed?
          sleep 1
          c.file 'config.rb', 'config.output_path = "output"'
          watcher.should be_config_changed
        end
      end
    end
  end
  
  describe '#process' do
    context 'with changes' do
      it 'calls site#process' do
        mock(Massimo::Site.new).process
        watcher = Massimo::Watcher.new(Massimo.site)
        mock(watcher).changed? { true }
        watcher.process
      end
    end
    
    context 'with config changes' do
      it 'calls site#reload' do
        site = Massimo::Site.new
        mock(site).reload
        mock(site).process
        watcher = Massimo::Watcher.new(site)
        mock(watcher).config_changed? { true }
        watcher.process
      end
    end
    
    context 'without changes' do
      it 'does not call site#process' do
        dont_allow(Massimo::Site.new).process
        watcher = Massimo::Watcher.new(Massimo.site)
        mock(watcher).changed? { false }
        watcher.process
      end
    end
  end
  
  describe '.start' do
    it 'runs a new Watcher' do
      mock(watcher = Object.new).run
      mock(Massimo::Watcher).new(Massimo.site) { watcher }
      Massimo::Watcher.start(Massimo.site)
    end
  end
end