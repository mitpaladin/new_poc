
require_relative 'valid_with_no_errors'

shared_examples 'it is valid with a valid body attribute' do
  context 'and a valid body is specified in the attributes, it' do
    let(:body) { 'A Body' }

    it_behaves_like 'it is valid'
  end # context 'and a valid body is specified in the attributes, it'
end
