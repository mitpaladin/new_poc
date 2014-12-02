
require 'spec_helper'

require 'update_post'

module Actions
  describe UpdatePost do
    let(:klass) { UpdatePost }
    let(:command) { klass.new post_slug, post_data, current_user }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_repo) { UserRepository.new }
    let(:author) do
      FactoryGirl.create(:user, :saved_user).tap { |user| user_repo.add user }
    end
    let(:post) do
      attributes = FactoryGirl.attributes_for :post, :saved_post,
                                              :published_post,
                                              author_name: author.name
      PostEntity.new(attributes).tap { |post| PostRepository.new.add post }
    end

    # regardless of parameters, these steps wire up the Wisper connection
    before :each do
      command.subscribe(subscriber).execute
    end

    context 'for the post author' do
      let(:current_user) { author }
      let(:post_slug) { post.slug }

      context 'updating supported attributes with new valid values' do
        let(:post_data) { { body: 'Updated Post Body', title: 'A New Title'} }

        it 'is successful' do
          expect(subscriber).to be_successful
          expect(subscriber).not_to be_failure
        end

        describe 'is successful, broadcasting a payload which' do
          let(:payload) { subscriber.payload_for(:success).first }

          it 'is a PostEntity' do
            expect(payload).to be_a PostEntity
          end

          it 'is a PostEntity with correct attributes' do
            attrib_keys = post.attributes.keys - post_data.keys - [:pubdate]
            attrib_keys.each { |key| expect(payload[key]).to eq post[key] }
            post_data.keys.each { |k| expect(payload[k]).to eq post_data[k] }
            if post.attributes.key? :pubdate
              expect(payload[:pubdate]).to be_within(0.5.seconds)
                .of post[:pubdate]
            end
          end
        end # describe 'is successful, broadcasting a payload which'
      end # context 'updating supported attributes with new valid values'

      context 'changing the publication state of the post' do
        context 'from published to draft' do
          let(:post_data) { { pubdate: nil } }

          it 'is successful' do
            expect(subscriber).to be_successful
            expect(subscriber).not_to be_failure
          end

          describe 'is successful, broadcasting a payload which' do
            let(:payload) { subscriber.payload_for(:success).first }

            it 'is a draft PostEntity' do
              expect(payload).to be_a PostEntity
              expect(payload).not_to be_published
              expect(payload).to be_draft
            end
          end # describe 'is successful, broadcasting a payload which'
        end # context 'from published to draft'
      end # context 'changing the publication state of the post'

      context 'attempting to update supported attributes with invalid values' do
        let(:post_data) { { title: '', body: '', image_url: '' } }

        it 'is unsuccessful' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'is unsuccessful, broadcasting a payload which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'is a JSON-encoded array with the correct error messages' do
            expected = [
              "Title can't be blank",
              'Body must be specified if image URL is omitted'
            ]
            messages = JSON.parse payload
            expect(messages).to eq expected
          end
        end # describe 'is unsuccessful, broadcasting a payload which'
      end # context 'attempting to update supported attributes with invalid...'
    end # context 'for the post author'

    context 'for a registered user other than the post author' do
      let(:current_user) do
        FactoryGirl.create(:user, :saved_user).tap { |user| user_repo.add user }
      end
      let(:post_slug) { post.slug }
      let(:post_data) { {} }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is the correct error message' do
          expected = "User #{current_user.name} is not the author of this post!"
          expect(payload).to eq expected
        end
      end # describe 'is unsuccessful, broadcasting a payload which'
    end # context 'for a registered user other than the post author'

    context 'for the Guest User' do
      let(:post_slug) { 'anything' }
      let(:post_data) { {} }
      let(:current_user) { UserRepository.new.guest_user.entity }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is the correct error message' do
          expect(payload).to eq 'Not logged in as a registered user!'
        end
      end # describe 'is unsuccessful, broadcasting a payload which'
    end # context 'for the Guest User'
  end # describe Actions::UpdatePost
end # module Actions