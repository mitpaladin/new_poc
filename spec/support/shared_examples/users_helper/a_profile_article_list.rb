
shared_examples 'a profile article list' do |fragment_builder|
  let(:post_count) { 5 }
  let(:user) { FactoryGirl.create :user, :saved_user }
  let(:pubdate) { Chronic.parse '3 days ago at 3 PM' }
  let!(:posts) do
    FactoryGirl.create_list :post, post_count, :saved_post, :published_post,
                            author_name: user.name,
                            pubdate: pubdate
  end
  let(:fragment) do
    fragment_builder.call helper.profile_article_list(user.name)
  end

  before :each do
    allow(helper).to receive(:current_user).and_return user
  end

  it 'generates an outermost ul.list-group element' do
    expected = Regexp.new '\A<ul class="list-group">.*?</ul>\z'
    expect(helper.profile_article_list user.name).to match expected
  end

  it 'contains the correct number of child elements' do
    expect(fragment).to have(5).nodes
  end

  # FIXME: There's *got* to be a better way to do this.
  describe 'for each child element of the ul.list-group element' do
    it 'is a li.list-group-item element' do
      fragment.nodes.each do |child|
        expect(child.name).to eq 'li'
        expect(child['class']).to eq 'list-group-item'
      end
    end

    describe 'for each li.list-group-item element' do
      it 'has a single child element' do
        fragment.nodes.each do |li|
          expect(li).to have(1).node
        end
      end

      it 'contains a child element with an "a" tag' do
        fragment.nodes.each do |li|
          expect(li.nodes.first.name).to eq 'a'
        end
      end

      describe 'contains a child anchor link with' do
        it 'an "href" attribute matching the currect article slug' do
          fragment.nodes.each_with_index do |li, li_index|
            slug = "/posts/#{posts[li_index].title.parameterize}"
            expect(li.nodes.first['href']).to eq slug
          end
        end

        it 'the correct text content' do
          fragment.nodes.each_with_index do |li, li_index|
            title = posts[li_index].title
            expected = [
              %("#{title}"),
              'Published',
              FeatureSpecTimestampHelper.to_timestamp_s(pubdate)
            ].join ' '
            expect(li.nodes.first.text).to eq expected
          end
        end
      end # describe 'contains a child anchor link with'
    end # describe 'for each li.list-group-item element'
  end # describe 'for each child element of the ul.list-group element'
end
