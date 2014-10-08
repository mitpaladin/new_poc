
require 'spec_helper'

# Specs for persistence entity-layer representation for User.
describe UserEntity do
  let(:klass) { UserEntity }
  let(:user_name) { 'Joe Palooka' }
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

  describe 'supports initialisation' do

    describe 'succeeding' do
      it 'with any combination of valid field names' do
        expect { klass.new valid_subset }.not_to raise_error
      end

      it 'with invalid field names' do
        expect { klass.new invalid_attribs }.not_to raise_error
      end
    end # describe 'succeeding'

    describe 'failing' do
      # Null entities aren't very useful. (Use Null Objects instead.)
      it 'with no parameters' do
        message = 'wrong number of arguments (0 for 1)'
        expect { klass.new }.to raise_error ArgumentError, message
      end
    end # describe 'failing'
  end # describe 'supports initialisation'

  describe 'instantiating with' do

    describe 'valid attribute names' do
      let(:obj) { klass.new valid_subset }

      it 'sets the attributes' do
        valid_subset.each_pair do |attrib, value|
          expect(obj.send attrib).to eq value
        end
      end
    end # describe 'valid attribute names'

    describe 'valid and invalid attribute names' do
      let(:obj) { klass.new valid_subset.merge(invalid_attribs) }

      it 'sets the valid attributes' do
        valid_subset.each_pair do |attrib, value|
          expect(obj.send attrib).to eq value
        end
      end

      it 'does not set attributes with invalid names' do
        invalid_attribs.each_key do |attrib|
          message = "`#{attrib}' is not allowed as an instance variable name"
          expect { obj.instance_variable_get attrib }
              .to raise_error NameError, message
        end
      end
    end # describe 'invalid attribute names'
  end # describe 'instantiating with'

  describe '#attributes' do
    let(:obj) { klass.new valid_subset }
    let(:actual) { obj.attributes }

    it 'returns the attributes passed to the initialiser' do
      valid_subset.each_pair do |attrib, value|
        expect(obj.send attrib).to eq value
      end
    end

    it 'returns only the attributes passed to the initialiser' do
      expect(actual.length).to eq valid_subset.keys.length
      all_attrib_keys.reject { |k| valid_subset.key? k }.each do |attrib|
        expect(obj.send attrib).to be nil
      end
    end
  end # describe '#attributes'

  describe '#persisted?' do
    it 'returns true if the "slug" attribute is present' do
      expect(klass.new valid_subset).to be_persisted
    end

    it 'returns false if the "slug" attribute is not present' do
      expect(klass.new name: user_name).not_to be_persisted
    end
  end # describe '#persisted?'
end # describe UserEntity
