
require 'spec_helper'

require 'session_new_action'

# Module DSO2 contains our second-generation Domain Service Objects, aka
#   "interactors".
module DSO2
  describe SessionNewAction do
    let(:klass) { SessionNewAction }

    it 'has :run and :run! methods that require no parameters' do
      expect { klass.run! }.not_to raise_error
    end

    describe 'returns a StoreResult instance with' do
      let(:result) { klass.run! }

      it 'a :success field of "true"' do
        expect(result).to be_success
      end

      it 'an empty :errors field' do
        expect(result.errors).to be_empty
      end

      describe 'an :entity field matching the Guest User settings for' do
        let(:entity) { result.entity }

        it 'name' do
          expect(entity.name).to eq 'Guest User'
        end

        it 'dummy password for testing' do
          expect(entity.password).to eq 'password'
          expect(entity.password_confirmation).to eq entity.password
        end

        it 'slug' do
          expect(entity.slug).to eq 'guest-user'
        end
      end # describe 'an :entity field matching the Guest User settings for'
    end # describe 'returns a StoreResult instance with'
  end # describe DSO2::SessionNewAction
end # module DSO2
