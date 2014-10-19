
require 'spec_helper'

require 'current_user_identity'

require 'support/shared_examples/users_helper/a_profile_article_list'
require 'support/shared_examples/users_helper/a_profile_bio_panel'

describe UsersHelper do
  let(:user) { FactoryGirl.create :user_datum }

  describe :profile_article_list.to_s do
    fragment_builder = lambda do |markup|
      Nokogiri.parse(markup).children.first
    end

    before :each do
      allow(controller).to receive(:authorize).and_return true
    end

    it_behaves_like 'a profile article list', fragment_builder
  end # describe :profile_article_list

  describe :profile_articles_row.to_s do
    let(:fragment) do
      Nokogiri.parse(profile_articles_row user.name).children.first
    end

    before :each do
      allow(controller).to receive(:authorize).and_return true
    end

    it 'is a div.row#contrib-row element' do
      expect(fragment.name).to eq 'div'
      expect(fragment['class']).to eq 'row'
      expect(fragment['id']).to eq 'contrib-row'
    end

    it 'has two child elements' do
      expect(fragment).to have(2).children
    end

    describe 'contains a first child element that' do
      let(:element) { fragment.children.first }

      it 'is an h3 element' do
        expect(element.name).to eq 'h3'
      end

      it 'contains the expected text, including the user name' do
        expected = ['Articles Authored By', user.name].join ' '
        expect(element.content).to eq expected
      end
    end # describe 'contains a first child element that'

    describe 'contains a second child element that is a profile article list' do
      fragment_builder = lambda do |markup|
        Nokogiri.parse(markup).children.last
      end
      it_behaves_like 'a profile article list', fragment_builder
    end # describe 'contains a second child element...a profile article list'
  end # describe :profile_articles_row

  describe :profile_bio_panel.to_s do
    fragment_builder = lambda do |markup|
      Nokogiri.parse(markup).children.first
    end
    it_behaves_like 'a profile bio panel', fragment_builder
  end # describe :profile_bio_panel

  describe :profile_bio_row.to_s do
    let(:fragment) do
      Nokogiri.parse(profile_bio_row user.name, user.profile).children.first
    end

    it 'is a div.row element' do
      expect(fragment.name).to eq 'div'
      expect(fragment['class']).to eq 'row'
    end

    it 'contains two child elements' do
      expect(fragment).to have(2).children
    end

    describe 'has a first child element that' do
      let(:child) { fragment.children.first }

      it 'is an h1 tag' do
        expect(child.name).to eq 'h1'
      end

      it 'contains text including the user name' do
        expect(child.content).to eq "Profile Page for #{user.name}"
      end
    end # describe 'has a first child element that'

    describe 'has a second child element that' do
      fragment_builder = lambda do |markup|
        Nokogiri.parse(markup).children.last
      end
      it_behaves_like 'a profile bio panel', fragment_builder
    end # describe 'has a second child element that'
  end # describe :profile_bio_row

  describe :profile_bio_header.to_s do
    let(:fragment) do
      Nokogiri.parse(profile_bio_header user.name).children.first
    end
    let(:header_text) { "Profile Page for #{user.name}" }

    it 'is a h1.bio element' do
      expect(fragment.name).to eq 'h1'
      expect(fragment['class']).to eq 'bio'
    end

    it 'contains the user name as its content' do
      expect(fragment.children.first.to_html).to eq header_text
    end

    context 'for the Guest User' do

      it 'contains only the single text node' do
        expect(fragment.children.length).to eq 1
        expect(fragment.children.first.name).to eq 'text'
      end
    end # context 'for the Guest User'

    context 'for a logged-in user that is' do
      let(:identity) { CurrentUserIdentity.new session }

      context 'NOT the user whose record is being shown, it' do
        let(:user2) { FactoryGirl.create :user_datum }
        let(:fragment) do
          identity.current_user = user2
          Nokogiri.parse(profile_bio_header user.name).children.first
        end

        it 'returns an empty text fragment' do
          expect(fragment.children.length).to eq 1
          expect(fragment.children.first.name).to eq 'text'
          expect(fragment.content).to eq header_text
        end
      end # context 'NOT the user whose record is being shown, it'

      context 'the user whose record is being shown' do
        let(:fragment) do
          identity.current_user = user
          Nokogiri.parse(profile_bio_header user.name).children.first
        end

        it 'returns a button-styled link linking to the user edit path' do
          expect(fragment.children.length).to eq 2
          link = fragment.children.last
          expect(link.name).to eq 'button'
          expect(link['class']).to eq 'btn btn-xs pull-right'
          expect(link['href']).to eq edit_user_path(user.slug)
          content = link.children.first
          expect(content.name).to eq 'text'
          expect(content.content).to eq 'Edit Your Profile'
        end
      end # context  'the user whose record is being shown'
    end # context 'for a logged-in user that is'
  end # describe :profile_bio_header
end # describe UsersHelper
