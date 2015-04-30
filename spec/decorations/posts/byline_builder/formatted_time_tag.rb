
shared_examples 'a correctly-formatted :time tag' do |status_string, time_in|
  describe 'has correct content for the :time tag, with' do
    let(:match_data) do
      expected = %r{<time.+>#{status_string} (.+) by (.+)</time>}
      actual.match expected
    end
    # let(:status_string) { 'Posted' }
    let(:what_time) do
      if match_data
        match_data.captures.first
      else
        :what_time_is_it_anyway?
      end
    end
    let(:time_value) { post.send(time_in) || Time.zone.now }

    it 'the correct overall format' do
      expect(match_data).not_to be nil
    end

    it 'the author name' do
      expect(match_data.captures.last).to eq post.author_name
    end

    it 'the correct time specified in the timestamp' do
      timestamp = Time.zone.parse what_time
      # RSpec can be *slow*.
      expect(timestamp).to be_within(1.minute).of time_value
    end

    it 'the timestamp in the correct semi-expanded format' do
      # Will match, e.g., 'Thu Apr 16 2015 at 00:40 SGT (+0800)' or
      # 'Thu Apr 15 2015 at 12:40 EDT (-0400)'
      regex = '[[:alpha:]]{3} [[:alpha:]]{3} {1,2}\d{1,2} \d{4}' \
        ' at \d{2}:\d{2} [[:upper:]]{3} \([-+]\d{4}\)'
      expect(what_time).to match regex
    end
  end # describe 'has correct content for the :time tag, with'
end
