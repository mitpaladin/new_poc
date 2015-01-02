
require 'spec_helper'

require 'newpoc/support/store_result'

module Newpoc
  # Support classes used by (possibly) multiple Newpoc modules.
  module Support
    describe StoreResult do
      let(:entity) { 'ENTITY' }
      let(:success) { true }
      let(:errors) { %w(errors go here) }

      it 'works as a simple value container' do
        obj = described_class.new entity: entity, success: success,
                                  errors: errors
        expect(obj.entity).to be entity
        expect(obj.success?).to be success
        expect(obj.errors).to be errors
      end

      it 'fails when an initialiser parameter is omitted' do
        params = { entity: entity, success: success }
        message = 'missing keyword: errors'
        expect { described_class.new params }
          .to raise_error ArgumentError, message
      end
    end # describe StoreResult
  end
end # module Newpoc
