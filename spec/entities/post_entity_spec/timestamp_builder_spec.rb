
require 'spec_helper'

require 'post_entity/timestamp_builder'

# Dummy test class for testing the EntityShared#timestamp_for function.
class DummyTestClass
  extend EntityShared
end

describe DummyTestClass do
  describe :timestamp_for do

    describe 'returns a formatted time/date string when' do
      it 'passed an explicit timestamp (having a #to_time method)' do
        the_time = Chronic.parse '21 August 2014 at 15:38:59 '
        pattern_str = 'Thu Aug 21 2014 at 15:38' \
          ' [[:upper:]]{3} \([\+\-][[:digit:]]{4}\)'
        expected = Regexp.new pattern_str
        expect(DummyTestClass.timestamp_for the_time).to match expected
      end

      it 'called without a parameter, as if called using the current time' do
        expected = DateTime.now.to_time.strftime DummyTestClass.timestamp_format
        expect(DummyTestClass.timestamp_for).to eq expected
      end
    end # describe 'returns a formatted time/date string when'
  end # describe :timestamp_for

  describe :timestamp_format do

    it 'returns the correct Time#strftime format string' do
      expected = '%a %b %e %Y at %R %Z (%z)'
      expect(DummyTestClass.timestamp_format).to eq expected
    end
  end
end # describe DummyTestClass
