
require 'spec_helper'

require 'cco/post_cco'

# Cross-layer conversion objects (CCOs).
module CCO
  describe PostCCO do
    let(:klass) { PostCCO }
    let(:post_attribs) { FactoryGirl.attributes_for :post_datum }
    let(:blog) { Blog.new }
    let(:new_post) { blog.new_post post_attribs }
    let(:saved_pubdate) { Time.now }
    let(:saved_post) do
      ret = blog.new_post post_attribs
      ret.publish saved_pubdate
      ret
    end
    let(:new_impl) { FactoryGirl.build :post_datum, :new_post }
    let(:saved_impl) { FactoryGirl.create :post_datum, :saved_post }

    it 'has a .from_entity class method' do
      p = klass.public_method :from_entity
      expect(p.receiver).to be klass
    end

    it 'has a .to_entity class method' do
      p = klass.public_method :to_entity
      expect(p.receiver).to be klass
    end

    describe :from_entity do
      it 'does not raise an error when called with a Post entity parameter' do
        expect { klass.from_entity new_post }.not_to raise_error
        expect { klass.from_entity saved_post }.not_to raise_error
      end

      it 'returns a PostData instance when called with a Post entity' do
        expect(klass.from_entity new_post).to be_a new_impl.class
        expect(klass.from_entity saved_post).to be_a new_impl.class
      end

      describe 'returns a PostData instance with correct values for' do
        let(:new_instance) { klass.from_entity new_post }
        let(:saved_instance) do
          ret = klass.from_entity saved_post
          ret.save!
          ret
        end

        it 'title' do
          expect(saved_instance.title).to eq saved_post.title
          expect(new_instance.title).to eq new_post.title
        end

        it 'body' do
          expect(saved_instance.body).to eq saved_post.body
          expect(new_instance.body).to eq new_post.body
        end

        describe 'pubdate' do

          it 'for an unpublished post' do
            expect(new_instance.pubdate).to eq new_post.pubdate
          end

          it 'for a published post' do
            expect(saved_instance.pubdate).to eq saved_pubdate
          end
        end # describe 'pubdate'

        describe 'created_at' do
          it 'for an unpublished post' do
            expect(new_instance.created_at).to eq new_post.created_at
          end

          it 'for a published post' do
            expect(saved_instance.created_at)
                .to be_within(0.1.second).of saved_pubdate
          end
        end # describe 'created_at'
      end # describe 'returns a PostData instance with correct values for'

      context 'when called on an existing model record' do
        let(:new_body) { 'THIS IS THE NEW BODY' }
        let(:impl) do
          ret = PostData.new post_attribs
          ret.save!
          ret
        end
        let(:entity) { klass.to_entity impl }

        it 'updates the existing record' do
          entity.body = new_body
          impl2 = klass.from_entity entity
          expect(impl2).not_to be_new_record
          expect(impl2.body).to eq new_body
        end

        # Remember that #changed_attributes is cleared on a saved record.
        it 'changes only the modified attribute' do
          entity.body = new_body
          impl2 = klass.from_entity entity
          expect(impl2.changed_attributes.keys).to eq ['body']
        end
      end # context 'when called on an existing model record'

      describe 'handles "post_status" attribute (Issue 100 et al)' do
        it 'for an unpublished post' do
          impl = klass.from_entity new_post
          expect(impl.post_status).to eq 'draft'
        end

        it 'for a published post' do
          impl = klass.from_entity saved_post
          expect(impl.post_status).to eq 'public'
        end
      end # 'handles "post_status" attribute (Issue 100 et al)'
    end # describe :from_entity

    describe :to_entity do
      it 'does not raise an error when called with a PostData parameter' do
        expect { klass.to_entity new_impl }.not_to raise_error
        expect { klass.to_entity saved_impl }.not_to raise_error
      end

      it 'returns a Post instance when called with a PostData instance' do
        expect(klass.to_entity new_impl).to be_a Post
        expect(klass.to_entity saved_impl).to be_a Post
      end

      describe 'returns a Post instance with correct values for' do
        let(:new_instance) { klass.to_entity new_impl }
        let(:saved_instance) { klass.to_entity saved_impl }

        it 'title' do
          expect(new_instance.title).to eq new_impl.title
          expect(saved_instance.title).to eq saved_impl.title
        end

        it 'body' do
          expect(new_instance.body).to eq new_impl.body
          expect(saved_instance.body).to eq saved_impl.body
        end

        describe 'pubdate' do

          it 'for an unpublished post' do
            expect(new_instance.pubdate).to eq new_impl.pubdate
          end

          it 'for a published post' do
            expect(saved_instance.pubdate).to eq saved_impl.pubdate
            expect(saved_instance).to be_published
          end
        end # describe 'pubdate'

        it 'created_at' do
          expect(saved_instance.created_at).to eq saved_impl.created_at
          expect(new_instance.created_at).to be_within(0.1.second).of Time.now
        end
      end # describe 'returns a PostData instance with correct values for'
    end # describe :to_entity
  end # describe CCO::Blog
end # module CCO
