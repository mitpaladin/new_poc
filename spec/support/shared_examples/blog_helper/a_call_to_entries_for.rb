
require 'post_decorator'

shared_examples 'a call to #entries_for' do |with_param|
  if with_param
    outer_context_desc = 'when specifying a parameter'
    blog = BlogData.first
  else
    outer_context_desc = 'without specifying a parameter'
  end
  is_decorated = !blog.nil?

  context outer_context_desc do

    context 'when no entries have been added to the blog' do

      it 'returns an empty array' do
        value = if blog.nil?
                  helper.entries_for
                else
                  helper.entries_for blog
                end
        expect(value).to be_an Array
        expect(value).to be_empty
      end
    end # context 'when no entries have been added to the blog'

    context 'when entries have been added to the blog' do
      let(:entry_count) { 10 }
      before :each do
        FactoryGirl.create_list :post_datum, entry_count
        @entries = if blog.nil?
                     helper.entries_for
                   else
                     helper.entries_for blog
                   end
      end

      describe 'returns an array with' do

        it 'the correct number of entries' do
          expect(@entries).to be_an Array
          expect(@entries).to have(entry_count).items
        end

        describe 'each item' do

          describe 'having the correct' do

            it 'title' do
              expr = /Test Title Number \d+/
              @entries.each { |entry| expect(entry.title).to match expr }
            end

            it 'body text' do
              @entries.each { |entry| expect(entry.body).to eq 'The Body' }
            end

            it 'image URL' do
              url = 'http://example.com/image1.png'
              @entries.each { |entry| expect(entry.image_url).to match url }
            end
          end # describe 'having the correct'

          it 'being a Post entity instance' do
            @entries.each { |entry| expect(entry).to be_a Post }
          end

          if is_decorated
            it 'decorated with a PostDecorator' do
              @entries.each do |entry|
                expect(entry).to be_decorated_with(PostDecorator)
              end
            end
          end # if is_decorated
        end # describe 'each item'
      end # describe 'returns an array with'
    end # context 'when entries have been added to the blog'
  end # context outer_context_desc
end # shared_examples

shared_examples 'a call to #entries_for with no parameters' do
  it_behaves_like 'a call to #entries_for'
end

shared_examples 'a call to #entries_for with a blog parameter' do
  it_behaves_like 'a call to #entries_for', true
end
