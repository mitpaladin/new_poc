
require 'spec_helper'

require 'cco/post_cco'

# Cross-layer conversion objects (CCOs).
module CCO
  describe PostCCO do
    let(:klass) { PostCCO }
    let(:blog) { Blog.new }
    let(:ctime) { Time.now }
    # new/saved, draft/public
    let(:new_draft_impl) do
      FactoryGirl.build :post_datum, :new_post, :draft_post, created_at: ctime
    end
    let(:saved_draft_impl) do
      FactoryGirl.build :post_datum, :saved_post, :draft_post, created_at: ctime
    end
    let(:new_public_impl) do
      FactoryGirl.build :post_datum, :new_post, :public_post, created_at: ctime
    end
    let(:saved_public_impl) do
      FactoryGirl.build :post_datum,
                        :saved_post,
                        :public_post,
                        created_at: ctime
    end
    let(:all_impls) do
      [
        saved_draft_impl,
        saved_public_impl,
        new_draft_impl,
        new_public_impl
      ]
    end
    let(:new_draft_post) do
      attribs = FactoryGirl.attributes_for :post_datum, :new_post, :draft_post
      blog.new_post attribs
    end
    let(:new_public_post) do
      attribs = FactoryGirl.attributes_for :post_datum, :new_post, :public_post
      blog.new_post attribs
    end
    let(:saved_draft_post) do
      attribs = FactoryGirl.attributes_for :post_datum, :saved_post, :draft_post
      blog.new_post attribs
    end

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
        expect { klass.from_entity new_draft_post }.not_to raise_error
        expect { klass.from_entity saved_draft_post }.not_to raise_error
      end

      it 'returns a PostData instance when called with a Post entity' do
        expected_class = new_draft_impl.class
        expect(klass.from_entity new_draft_post).to be_a expected_class
        expect(klass.from_entity saved_draft_post).to be_a expected_class
      end

      describe 'returns a PostData instance with correct values for' do

        it 'title' do
          all_impls.each do |impl|
            instance = klass.from_entity impl
            expect(instance.title).to eq impl.title
          end
        end

        it 'body' do
          all_impls.each do |impl|
            instance = klass.from_entity impl
            expect(instance.body).to eq impl.body
          end
        end

        describe 'pubdate' do

          it 'for an unpublished post' do
            [saved_draft_impl, new_draft_impl].each do |impl|
              expect(impl.pubdate).to be nil
            end
          end

          it 'for a published post' do
            [saved_public_impl, new_public_impl].each do |impl|
              expect(impl.pubdate).to be_within(1.second).of Time.now
            end
          end
        end # describe 'pubdate'

        describe 'created_at' do
          it 'for both published and unpublished posts' do
            all_impls.each { |impl| expect(impl.created_at).to eq ctime }
          end
        end # describe 'created_at'
      end # describe 'returns a PostData instance with correct values for'

      context 'when called on an existing model record' do
        let(:new_body) { 'THIS IS THE NEW BODY' }
        let(:entity) do
          saved_draft_impl.save!
          klass.to_entity saved_draft_impl
        end

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
          impl = klass.from_entity new_draft_post
          expect(impl.post_status).to eq 'draft'
        end

        it 'for a published post' do
          impl = klass.from_entity new_public_post
          expect(impl.post_status).to eq 'public'
        end
      end # 'handles "post_status" attribute (Issue 100 et al)'
    end # describe :from_entity

    describe :to_entity do
      it 'does not raise an error when called with a PostData parameter' do
        all_impls.each do |impl|
          expect { klass.to_entity impl }.not_to raise_error
        end
      end

      it 'returns a Post instance when called with a PostData instance' do
        all_impls.each do |impl|
          expect(klass.to_entity impl).to be_a Post
        end
      end

      describe 'returns a Post instance with correct values for' do
        let(:impls) do
          ret = {}
          ret[:new_draft_impl] = new_draft_impl
          ret[:new_public_impl] = new_public_impl
          ret[:saved_draft_impl] = saved_draft_impl
          ret[:saved_public_impl] = saved_public_impl
          ret
        end

        it 'title' do
          impls.keys.each do |impl_key|
            entity = klass.to_entity impls[impl_key]
            expect(entity.title).to eq impls[impl_key].title
          end
        end

        it 'body' do
          impls.keys.each do |impl_key|
            entity = klass.to_entity impls[impl_key]
            expect(entity.body).to eq impls[impl_key].body
          end
        end

        it 'pubdate' do
          impls.keys.each do |impl_key|
            entity = klass.to_entity impls[impl_key]
            expect(entity.pubdate).to eq impls[impl_key].pubdate
          end
        end
      end # describe 'returns a PostData instance with correct values for'
    end # describe :to_entity
  end # describe CCO::Blog
end # module CCO
