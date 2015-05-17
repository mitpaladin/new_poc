
require 'spec_helper'

describe UsersController::Action::Create::EntityExistsFailure do
  let(:attributes) { FactoryGirl.attributes_for :user, :saved_user }
  let(:params) { { slug: slug, attributes: attributes } }
  let(:slug) { attributes[:slug] }

  describe 'is initalised' do
    let(:user_exists?) { false }
    it 'successfully with parameters for :slug and :attributes' do
      expect { described_class.new params }.not_to raise_error
    end
  end # describe 'is initialised'

  describe 'has a #fail method that' do
    it 'raises an error using the initialiser parameters as data' do
      expect { described_class.new(params).fail }.to raise_error do |e|
        payload = YAML.load e.message
        expect(payload).to be_a Hash
        expect(payload[:messages].count).to eq 1
        expected = "A record identified by slug '#{attributes[:slug]}'" \
          ' already exists!'
        expect(payload[:messages].first).to eq expected
        expect(payload[:attributes]).to eq attributes
      end
    end
  end # describe 'has a #fail method that'
end # describe UsersController::Action::Create::EntityExistsFailure
