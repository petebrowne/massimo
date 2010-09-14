require 'spec_helper'

describe Massimo::UI do
  describe '.say' do
    it 'should print out the given message to stdout' do
      mock($stdout).puts 'message'
      Massimo::UI.say 'message'
    end
    
    it 'should not send a Growl notification' do
      dont_allow(Growl).notify
      Massimo::UI.say 'message'
    end
    
    context 'with a color' do
      it 'should print out the message with the correct color code' do
        mock($stdout).puts "\e[31mmessage\e[0m"
        Massimo::UI.say 'message', :red
      end
    end
    
    context 'with :growl => true' do
      it 'should send a Growl Notification' do
        mock(Growl).notify('message', anything)
        Massimo::UI.say 'message', :growl => true
      end
      
      context 'and a color' do
        it 'should send an uncolored Growl Notification' do
          mock(Growl).notify('message', anything)
          Massimo::UI.say 'message', :red, :growl => true
        end
      end
    end
  end
  
  describe '.color' do
    it 'should wrap the given message with the correct color code' do
      Massimo::UI.color('message', :red).should == "\e[31mmessage\e[0m"
    end
  end
  
  describe '.indent' do
    context 'within the block' do
      it 'should indent messages' do
        Massimo::UI.indent do
          mock($stdout).puts '  message'
          Massimo::UI.say 'message'
        end
      end
      
      context 'with another .indent' do
        it 'should further indent the messages' do
          Massimo::UI.indent do
            Massimo::UI.indent do
              mock($stdout).puts '    message'
              Massimo::UI.say 'message'
            end
          end
        end
      end
    end
    
    context 'after the block' do
      it 'should return to the original indent' do
        Massimo::UI.indent {}
        mock($stdout).puts 'message'
        Massimo::UI.say 'message'
      end
    end
  end
  
  describe '.report_errors' do
    it 'should swallow errors' do
      stub($stdout).puts
      expect {
        Massimo::UI.report_errors do
          raise ArgumentError
        end
      }.to_not raise_error
    end
    
    it 'should report the error' do
      mock($stdout) do |expect|
        expect.puts(/massimo/i)
        expect.puts(/ArgumentError/)
        expect.puts(/:\d+/)
      end
      Massimo::UI.report_errors do
        raise ArgumentError
      end
    end
  end
end