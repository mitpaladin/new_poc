
require 'spec_helper'

describe UsersController::Action::Create::UserDataConverter do
  let(:source_data) do
    {
      name: 'User Name',
      slug: 'user-name',
      profile: "This *is* a profile.\n" \
        'It would be meaningless to anyone except #1.' \
        ' And that will cost you £25.'
    }
  end

  describe 'has initialisation that does not fail with a parameter of' do
    it 'an empty string' do
      expect { described_class.new '' }.not_to raise_error
    end

    it 'an arbitrary, unencoded string' do
      expect { described_class.new 'this is input' }.not_to raise_error
    end

    it 'a query-string-formatted Hash' do
      expect { described_class.new source_data.to_query }.not_to raise_error
    end
  end # describe 'has initialisation that does not fail with a parameter of'

  describe 'when initialised with a query-formatted Hash, #data returns' do
    let(:obj) { described_class.new source_data.to_query }

    it 'an encapsulation of a Hash identical to the original source data' do
      expect(obj.data.to_hash).to eq source_data
    end

    it 'an object with attribute reader methods for each Hash key' do
      source_data.each do |k, v|
        expect(obj.data.send k).to eq v
      end
    end
  end
end # describe UsersController::Action::Create::UserDataConverter
