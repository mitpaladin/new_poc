
require 'spec_helper'

require_relative 'shared_examples/a_data_mapping_entity'

# Specs for persistence entity-layer representation for User.
describe UserEntity do
  let(:klass) { UserEntity }
  let(:user_name) { 'Joe Palooka' }
  let(:user_email) { 'joe@example.com' }
  let(:user_profile) { 'Whatever.' }
  let(:valid_subset) do
    {
      name: user_name,
      slug: user_name.parameterize,
      profile: user_profile
    }
  end
  let(:invalid_attribs) do
    {
      bogus: 'This is invalid',
      forty_two: 41
    }
  end
  let(:all_attrib_keys) do
    %w(created_at email name password password_confirmation profile slug
       updated_at).map(&:to_sym).to_a
  end

  it_behaves_like 'a data-mapping entity'

  describe :valid?.to_s do

    describe 'returns true when initialised with' do
      after :each do
        expect(klass.new @attribs).to be_valid
      end

      it 'a name and an email address' do
        @attribs = { name: user_name, email: user_email }
      end

      it 'a name, email address, and profile string' do
        @attribs = {
          name: user_name,
          email: user_email,
          profile: user_profile
        }
      end

      it 'a name, email address, profile string and password pair' do
        @attribs = {
          name: user_name,
          email: user_email,
          profile: user_profile,
          password: 'password',
          password_confirmation: 'password'
        }
      end

      it 'a name, email address, and password pair (no profile)' do
        @attribs = {
          name: user_name,
          email: user_email,
          password: 'password',
          password_confirmation: 'password'
        }
      end
    end # describe 'returns true when initialised with'

    describe 'returns false when initialised with' do
      after :each do
        expect(klass.new @attribs).not_to be_valid
      end

      it 'an invalid name' do
        name = '  Some  Body '
        @attribs = { name: name, email: user_email, profile: user_profile }
      end

      it 'no name' do
        @attribs = { email: user_email, profile: user_profile }
      end

      it 'no email address' do
        @attribs = { name: user_name, profile: user_profile }
      end

      it 'an invalid email address' do
        @attribs = { name: user_name, email: 'joe at example dot com' }
      end

      it 'a mismatched password pair' do
        @attribs = {
          name: user_name,
          email: user_email,
          password: 'password',
          password_confirmation: 'p@ssw0rD'
        }
      end
    end # describe 'returns false when initialised with'
  end # describe :valid?.to_s

  describe :formatted_profile.to_s do
    let(:profile) { 'This *is* a test.' }
    let(:user) { klass.new FactoryGirl.attributes_for :user, profile: profile }

    it 'returns the profile string, parsing Markdown to HTML' do
      expected = "<p>This <em>is</em> a test.</p>\n"
      expect(user.formatted_profile).to eq expected
    end
  end # describe :formatted_profile

  describe :guest_user?.to_s do

    it 'returns true for a guest user' do
      user = UserRepository.new.guest_user.entity
      expect(user).to be_guest_user
    end

    it 'returns false for a registered user' do
      user = UserEntity.new valid_subset
      expect(user).not_to be_guest_user
    end
  end # describe :guest_user?

  describe :sort.to_s do
    let(:low_user) do
      klass.new FactoryGirl.attributes_for :user, name: 'Abe Zonker'
    end
    let(:high_user) do
      klass.new FactoryGirl.attributes_for :user, nme: 'Zig Adler'
    end

    it 'returns the sorted array when source is not in order by name' do
      items = [high_user, low_user]
      expect(items.sort).to eq [low_user, high_user]
    end

    it 'returns a copy of the original array when in order by name' do
      items = [low_user, high_user]
      items.sort.each_with_index do |item, index|
        expect(item).to be items[index]
      end
      expect(items.sort).not_to be items
    end
  end # describe :sort
end # describe UserEntity
