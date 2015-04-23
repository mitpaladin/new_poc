
require 'spec_helper'

describe PostDao::Presentation do
  let(:dao_class) { PostDao }
  let(:draft_post) { dao_class.new(draft_attribs).extend described_class }
  let(:draft_attribs) do
    FactoryGirl.attributes_for :post, :saved_post
  end
  let(:published_post) do
    dao_class.new(published_attribs).extend described_class
  end
  let(:published_attribs) do
    FactoryGirl.attributes_for :post, :saved_post, :published_post
  end

  describe 'has a method #draft? that' do
    context 'for a draft post' do
      it 'returns true' do
        expect(draft_post).to be_draft
      end
    end # context 'for a draft post'

    context 'for a published post' do
      it 'returns false' do
        expect(published_post).not_to be_draft
      end
    end # context 'for a published post'
  end # describe 'has a method #draft? that' do

  describe 'has a method #published? that' do
    context 'for a draft post' do
      it 'returns false' do
        expect(draft_post).not_to be_published
      end
    end # context 'for a draft post'

    context 'for a published post' do
      it 'returns true' do
        expect(published_post).to be_published
      end
    end # context 'for a published post'
  end # describe 'has a method #published? that'

  describe 'has a virtual attribute :post_status that' do
    describe 'supports a writer such that setting the value to' do
      context '"draft"' do
        it 'sets the :pubdate field to nil' do
          published_post.post_status = 'draft'
          expect(published_post.pubdate).to be_nil
        end
      end # context '"draft"'

      context '"public"' do
        it 'sets the :pubdate field to the current time' do
          draft_post.post_status = 'public'
          expect(draft_post.pubdate).to be_within(5.seconds).of Time.zone.now
        end
      end # context '"public"'

      context 'an invalid string' do
        it 'does not affect the :pubdate field' do
          original = published_post.pubdate
          published_post.post_status = 'bogus'
          expect(published_post.pubdate).to eq original
        end
      end # context 'an invalid string'
    end # describe 'supports a writer such that setting the value to'

    describe 'supports a reader such that' do
      context 'for a public post' do
        it 'returns the string "public"' do
          expect(published_post.post_status).to eq 'public'
        end
      end # context 'for a public post'

      context 'for a draft post' do
        it 'returns the string "draft"' do
          expect(draft_post.post_status).to eq 'draft'
        end
      end # context 'for a draft post'
    end # describe 'supports a reader such that'
  end # describe 'has a virtual attribute :post_status that'
end # describe PostDao::Presentation
