
shared_examples 'byline markup for' do |byline_start|
  describe 'returns markup wrapped in an outermost :p tag' do
    let(:p_content) { markup.match(%r{\A<p>(.+)</p>\z})[1] }

    describe 'wrapping a :time tag' do
      let(:time_regex) { %r{<time pubdate="(.+)">(.+)</time>} }
      let(:time_matches) { p_content.match(time_regex).captures }

      it 'with a :pubdate attribute of "pubdate"' do
        expect(time_matches.first).to eq 'pubdate'
      end

      describe 'wrapping byline content that' do
        let(:byline_regex) { /(\w+) (.+) by (.+)/ }
        let(:byline_matches) do
          time_matches.last.match(byline_regex).captures
        end

        it "begins with the text '#{byline_start}" do
          expect(byline_matches.first).to eq byline_start
        end

        it 'contains the publication or last-updated-at date and time' do
          # Huge margin because the byline only shows HH:MM timestamp
          expect(Time.zone.parse byline_matches[1])
            .to be_within(1.minute).of published_attrs.updated_at
        end

        it 'ends with the author name' do
          expect(byline_matches.last).to eq published_attrs.author_name
        end
      end # describe 'wrapping byline content that'
    end # describe 'wrapping a :time tag'
  end # describe 'returns markup wrapped in an outermost :p tag'
end # shared_examples 'byline markup for'
