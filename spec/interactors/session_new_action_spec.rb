
require 'spec_helper'

require 'session_new_action'
require_relative 'shared_examples/a_storeresult_with_a_guest_user_entity'
require_relative 'shared_examples/a_successful_storeresult'

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

      it_behaves_like 'a successful StoreResult'
      it_behaves_like 'a StoreResult with a Guest User entity'
    end # describe 'returns a StoreResult instance with'
  end # describe DSO2::SessionNewAction
end # module DSO2
