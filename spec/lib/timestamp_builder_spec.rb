
require 'spec_helper'
require 'time'

require 'timestamp_builder'

describe TimestampBuilder do
  let(:test_class) do
    Class.new do
      include TimestampBuilder
    end
  end

  before :each do
    Time.zone = 'Asia/Tokyo'
    Chronic.time_class = Time.zone
  end

  describe 'exposes a #timestamp_for method that' do
    let(:obj) { test_class.new }

    it 'takes one optional argument' do
      method = obj.method :timestamp_for
      expect(method.arity).to eq(-1)
    end

    it 'uses the current time by default' do
      time_now = Time.zone.now
      actual_stamp = obj.timestamp_for
      expected_stamp = time_now.strftime obj._timestamp_format
      expect(actual_stamp).to eq expected_stamp
    end

    it 'accepts a Time instance as a parameter' do
      time_when = Chronic.parse('14 March 2015 at 9:26:54 AM')
      actual_time = Time.zone.at(time_when)
      expected = 'Sat Mar 14 2015 at 09:26 JST (+0900)'
      expect(obj.timestamp_for actual_time).to eq expected
    end
  end # describe 'exposes a #timestamp_for method that'
end # describe TimestampBuilder
