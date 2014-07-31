
shared_examples 'a profile bio panel' do
  let(:user) { FactoryGirl.create :user_datum }
  let(:fragment) do
    Nokogiri.parse(profile_bio_panel(user.profile)).children.first
  end

  it 'generates an outermost div.panel.panel-default element' do
    expected = Regexp.new '\A<div class="panel panel-default">.*?</div>\z'
    expect(profile_bio_panel user.profile).to match expected
  end

  it 'contains a single child element' do
    expect(fragment).to have(1).child
  end

  describe 'contains a child element that' do
    let(:child) { fragment.children.first }

    it 'is a div.panel-heading element' do
      expect(child.name).to eq 'div'
      expect(child['class']).to eq 'panel-heading'
    end

    describe 'itself contains an element that' do
      let(:heading) { child.children.first }

      it 'is an h3.panel-title element' do
        expect(heading.name).to eq 'h3'
        expect(heading['class']).to eq 'panel-title'
      end

      it 'has the correct title content' do
        expect(heading.content).to eq 'User Profile/Bio Information'
      end
    end # describe 'itself contains an element that'
  end # describe 'contains a child element that'
end # shared_examples 'a profile bio panel'
