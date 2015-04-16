
require 'spec_helper'

require 'current_user_identity'

require 'support/shared_examples/users_helper/a_profile_article_list'
require 'support/shared_examples/users_helper/a_profile_bio_panel'

describe UsersHelper do
  let(:user) { FactoryGirl.create :user, :saved_user }

  before :each do
    Time.zone = 'Asia/Singapore'
  end

  describe :profile_article_list.to_s do
    fragment_builder = lambda do |markup|
      Nokogiri.parse(markup).children.first
    end

    it_behaves_like 'a profile article list', fragment_builder
  end # describe :profile_article_list

  describe :profile_articles_row.to_s do
    let(:fragment) do
      allow(helper).to receive(:current_user).and_return true
      Nokogiri.parse(helper.profile_articles_row user.name).children.first
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

  describe :profile_bio_row.to_s do
    let(:actual) { profile_bio_row user.name, user.profile }
    let(:fragment) { Nokogiri.parse(actual).children.first }

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
      it_behaves_like 'a profile bio panel', fragment_builder, helper
    end # describe 'has a second child element that'
  end # describe :profile_bio_row
end # describe UsersHelper
