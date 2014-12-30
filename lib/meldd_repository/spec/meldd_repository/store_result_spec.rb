
require 'spec_helper'

require 'meldd_repository/store_result'

# MelddRepository: includes base Repository class wrapping database access.
module MelddRepository
  describe StoreResult do
    let(:entity) { 'ENTITY' }
    let(:success) { true }
    let(:errors) { %w(errors go here) }

    it 'works as a simple value container' do
      obj = described_class.new entity: entity, success: success, errors: errors
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
  end
end # module MelddRepository
