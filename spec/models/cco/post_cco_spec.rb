
require 'spec_helper'

require 'cco/post_cco'

# Cross-layer conversion objects (CCOs).
module CCO
  describe PostCCO do
    let(:klass) { PostCCO }
    let(:post_attribs) { FactoryGirl.attributes_for :post_datum }
    let(:blog) { Blog.new }
    let(:post) { blog.new_post post_attribs }
    let(:impl) { PostData.new post_attribs }

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
        expect { klass.from_entity post }.not_to raise_error
      end

      it 'returns a PostData instance when called with a Post entity' do
        expect(klass.from_entity post).to be_a impl.class
      end

      describe 'returns a PostData instance with correct values for' do
        let(:instance) { klass.from_entity post }

        it 'title' do
          expect(instance.title).to eq post.title
        end

        it 'body' do
          expect(instance.body).to eq post.body
        end

        describe 'pubdate' do

          it 'for an unpublished post' do
            expect(instance.pubdate).to eq post.pubdate
          end

          it 'for a published post' do
            stamp = Time.now
            post.publish stamp
            instance = klass.from_entity post
            expect(instance.pubdate).to eq post.pubdate
          end
        end # describe 'pubdate'
      end # describe 'returns a PostData instance with correct values for'
    end # describe :from_entity

    describe :to_entity do
      it 'does not raise an error when called with a PostData parameter' do
        expect { klass.to_entity impl }.not_to raise_error
      end

      it 'returns a Post instance when called with a PostData instance' do
        expect(klass.to_entity impl).to be_a Post
      end

      describe 'returns a Post instance with correct values for' do
        let(:instance) { klass.to_entity impl }

        it 'title' do
          expect(instance.title).to eq impl.title
        end

        it 'body' do
          expect(instance.body).to eq impl.body
        end

        describe 'pubdate' do

          it 'for an unpublished post' do
            expect(instance.pubdate).to eq impl.pubdate
          end

          it 'for a published post' do
            stamp = Time.now
            impl.pubdate = stamp
            impl.save!
            instance = klass.to_entity impl
            expect(instance.pubdate).to eq impl.pubdate
            expect(instance).to be_published
          end
        end # describe 'pubdate'
      end # describe 'returns a PostData instance with correct values for'
    end # describe :to_entity
  end # describe CCO::Blog
end # module CCO
