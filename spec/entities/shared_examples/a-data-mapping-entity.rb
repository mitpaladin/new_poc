
require_relative 'slug-based-persistence-checking'
require_relative 'initialiser-set-attributes'
require_relative 'supports-entity-initialisation'

shared_examples 'a data-mapping entity' do
  it_behaves_like 'it supports entity initialisation'
  it_behaves_like 'it has initialiser-set attributes'
  it_behaves_like 'it has slug-based persistence-status checking'
end

