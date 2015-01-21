
shared_examples 'a profile bio panel' do |fragment_builder, h|
  let(:user_entity) { Newpoc::Entity::User }
  let(:user) { user_entity.new FactoryGirl.attributes_for(:user) }
  let(:fragment) do
    builder = ProfileBioPanelBuilder.new user.profile.squish, h
    fragment_builder.call builder.to_html
  end

  it 'generates an outermost div.panel.panel-default element' do
    expect(fragment.name).to eq 'div'
    classes = fragment['class'].split
    expect(classes.sort).to eq ['panel', 'panel-default']
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
