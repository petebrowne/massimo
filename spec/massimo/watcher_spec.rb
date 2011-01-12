require 'spec_helper'

describe Massimo::Watcher do
  let(:site)    { Massimo::Site.new(:lib_path => 'libs') }
  let(:watcher) { Massimo::Watcher.new(site) }
  
  it 'should not have changed' do
    watcher.should_not be_changed
  end
  
  def with_files(check_once = true)
    within_construct do |construct|
      construct.file 'pages/index.haml'
      watcher.changed? if check_once
      yield construct
    end
  end
    
  context 'when a file is added' do
    it 'should have changed' do
      with_files(false) do |c|
        watcher.should be_changed
      end
    end
    
    context 'then checked without changes' do
      it 'should not have changed' do
        with_files do |c|
          watcher.should_not be_changed
        end
      end
    end
  end
  
  context 'when a file is removed' do
    it 'should have changed' do
      with_files do |c|
        File.delete 'pages/index.haml'
        watcher.should be_changed
      end
    end
  end
  
  context 'when a file is updated' do
    it 'should have changed' do
      with_files do |c|
        sleep 1
        File.open('pages/index.haml', 'w+') { |file| file.write('change') }
        watcher.should be_changed
      end
    end
  end
  
  describe '#process' do
    context 'with changes' do
      it 'should call site#process' do
        mock(Massimo::Site.new).process
        watcher = Massimo::Watcher.new(Massimo.site)
        mock(watcher).changed? { true }
        watcher.process
      end
    end
    
    context 'without changes' do
      it 'should not call site#process' do
        dont_allow(Massimo::Site.new).process
        watcher = Massimo::Watcher.new(Massimo.site)
        mock(watcher).changed? { false }
        watcher.process
      end
    end
  end
  
  describe '.start' do
    it 'should run a new Watcher' do
      mock(watcher = Object.new).run
      mock(Massimo::Watcher).new(Massimo.site) { watcher }
      Massimo::Watcher.start(Massimo.site)
    end
  end
end