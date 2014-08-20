
require_relative 'sequencer'

require 'pry'

describe Sequencer do
  context 'by default' do
    let(:obj) { Sequencer.new 'This is a Test %d' }

    describe 'takes a format string as a parameter and' do
      it 'acts as a string using that format' do
        expect(String(obj)).to match(/This is a Test \d+?/)
      end

      it 'returns the same string from repeated calls to #to_s/#to_str' do
        (1..50).each do
          expect(obj.to_str).to eq 'This is a Test 1'
        end
      end
    end # describe 'takes a format string as a parameter and'

    describe 'increments the sequence number' do

      it 'once when #step is called once' do
        obj.step
        expect(obj.to_str).to eq 'This is a Test 2'
      end

      it 'once for each call to #step' do
        50.times { obj.step }
        expect(obj.to_str).to eq 'This is a Test 51'
      end
    end # describe 'increments the sequence number'
  end # context 'by default'

  context 'with an explicitly-specified starting number' do
    let(:sequence_start) { 500 }
    let(:obj) { Sequencer.new 'This is a Test %d', sequence_start }

    it 'returns the sequence starting number each time #to_s is called' do
      expected = "This is a Test #{sequence_start + 1}"
      (1..50).each do
        # NOTE: Comparing the raw object doesn't work even if Sequencer is
        # Comparable and the spaceship operator is called and returns true. WtF?
        expect("#{obj}").to eq expected
      end
    end
  end # context 'with an explicitly-specified starting number'

  context 'with the auto_step constructor parameter set to true' do
    let(:obj) { Sequencer.new 'This is a Test %d', 0, true }

    it 'increments the internal counter each time #to_s is called' do
      step_count = 50
      step_count.times do |step_value|
        expect(obj.to_s).to eq "This is a Test #{step_value + 1}"
      end
    end
  end # context 'with the auto_step constructor parameter set to true'

  it 'can interoperate as a String instance' do
    obj = Sequencer.new 'This is a Test %d'
    expect('foo ' + obj).to eq 'foo This is a Test 1'
  end
end
