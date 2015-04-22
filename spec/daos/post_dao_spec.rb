
require 'spec_helper'

describe PostDao do
  let(:draft_post) { described_class.new draft_attribs }
  let(:draft_attribs) do
    FactoryGirl.attributes_for :post, :saved_post
  end
  let(:published_post) { described_class.new published_attribs }
  let(:published_attribs) do
    FactoryGirl.attributes_for :post, :saved_post, :published_post
  end

  describe 'supports initialisation' do
    it 'with no parameters' do
      expect { described_class.new }.not_to raise_error
    end

    it 'with a title parameter string only' do
      expect { FactoryGirl.create :post, body: nil }.not_to raise_error
    end

    it 'with all defined parameter values' do
      attribs = FactoryGirl.attributes_for :post, :image_post, :saved_post,
                                           :published_post
      expect { described_class.new attribs }.not_to raise_error
    end
  end # describe 'supports initialisation'

  describe 'reports validation correctly, showing that an instance' do
    let(:author_name) { 'Joe Palooka' }
    let(:title) { 'The Title' }

    describe 'is valid for an instance created with' do
      it 'an instance with an author name and a title' do
        subject = described_class.new author_name: author_name, title: title
        expect(subject).to be_valid
      end
    end # describe 'is valid for an instance created with'

    describe 'is invalid for an instance created with' do
      it 'no parameters' do
        expect(described_class.new).not_to be_valid
      end

      it 'a title but no author name' do
        expect(described_class.new title: title).not_to be_valid
      end

      it 'an author name but no title' do
        expect(described_class.new author_name: author_name).not_to be_valid
      end
    end # describe 'is invalid for an instance created with'
  end # describe 'reports validation correctly, showing that an instance'

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
end # describe PostDao
