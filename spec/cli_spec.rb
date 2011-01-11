require 'spec_helper'

describe Massimo::CLI do
  describe '#server' do
    it 'starts a server at port 3000' do
      silence(:stdout) do
        mock(Massimo::Server).start is_a(Massimo::Site), 3000
        Massimo::CLI.start(%w(server))
      end
    end
    
    context 'with a given port number' do
      it 'starts a server at the given port' do
        silence(:stdout) do
          mock(Massimo::Server).start is_a(Massimo::Site), 1234
          Massimo::CLI.start(%w(server 1234))
        end
      end
    end
    
    context "with mapping 's'" do
      it 'starts a server at port 3000' do
        silence(:stdout) do
          mock(Massimo::Server).start is_a(Massimo::Site), 3000
          Massimo::CLI.start(%w(s))
        end
      end
    end
  end
  
  describe '#watch' do
    it 'watches the files for changes' do
      silence(:stdout) do
        mock(Massimo::Watcher).start is_a(Massimo::Site)
        Massimo::CLI.start(%w(watch))
      end
    end
    
    context "with mapping 'w'" do
      it 'watches the files for changes' do
        silence(:stdout) do
          mock(Massimo::Watcher).start is_a(Massimo::Site)
          Massimo::CLI.start(%w(w))
        end
      end
    end
  end
  
  describe '#version' do
    it 'prints out the current version number' do
      output = capture(:stdout) { Massimo::CLI.start(%w(version)) }
      output.strip.should == Massimo::VERSION
    end
    
    %w(v -v --version).each do |mapping|
      context "with mapping '#{mapping}'" do
        it 'prints out the current version number' do
          output = capture(:stdout) { Massimo::CLI.start(%W(#{mapping})) }
          output.strip.should == Massimo::VERSION
        end
      end
    end
  end
end
