
require 'spec_helper'

describe UsersController::Action::Update::UserDataFilter do
  describe 'supports initialisation with a Hash that has' do
    after :each do
      expect { described_class.new @param }.not_to raise_error
    end

    it 'string keys' do
      @param = { 'name': 'Some User', 'profile': 'A Profile' }
    end

    it 'symbolic keys' do
      @param = { name: 'Some User', profile: 'A Profile' }
    end
  end # describe 'supports initialisation with a Hash that has'

  describe 'has a #filter method that, when initialised with' do
    context 'a Hash where every key matches a permitted attribute, it' do
      let(:init_data) { { email: 'user@example.com', profile: 'A Profile' } }
      let(:obj) { described_class.new init_data }
      let(:filtered) { obj.filter }

      describe 'sets the :data attribute to an object which can be accessed' do
        it 'via a Hash to read those attributes' do
          init_data.each_key do |k|
            expect(filtered.data[k]).to eq init_data[k]
          end
        end

        it 'via a method with the attribute name to read its value' do
          init_data.each_key do |k|
            expect(filtered.data.send k).to eq init_data[k]
          end
        end
      end # describe '...the :data attribute to an object which can be accessed'
    end # context 'a Hash where every key matches a permitted attribute, it'
  end # describe 'has a #filter method that, when initialised with'
end
