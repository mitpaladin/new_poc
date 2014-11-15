
require 'spec_helper'

describe StoreResult do
  let(:klass) { StoreResult }
  let(:entity) { 'ENTITY' }
  let(:success) { true }
  let(:errors) { %w(errors go here) }

  it 'works as a simple value container' do
    obj = klass.new entity: entity, success: success, errors: errors
    expect(obj.entity).to be entity
    expect(obj.success?).to be success
    expect(obj.errors).to be errors
  end

  it 'fails when an initialiser parameter is omitted' do
    params = { entity: entity, success: success }
    message = 'missing keyword: errors'
    expect { klass.new params }.to raise_error ArgumentError, message
  end
end
