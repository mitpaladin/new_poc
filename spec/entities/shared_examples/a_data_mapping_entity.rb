
require_relative 'slug_based_persistence_checking'
require_relative 'initialiser_set_attributes'
require_relative 'supports_entity_initialisation'

shared_examples 'a data-mapping entity' do
  it_behaves_like 'it supports entity initialisation'
  it_behaves_like 'it has initialiser-set attributes'
  it_behaves_like 'it has slug-based persistence-status checking'
end
