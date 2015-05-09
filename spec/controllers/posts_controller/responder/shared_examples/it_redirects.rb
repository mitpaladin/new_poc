
shared_examples 'it redirects' do
  describe 'redirects' do
    let(:redirect) { fake_controller.redirects.first }
    let(:redirect_path) { redirect.first }
    let(:redirect_options) { redirect.last }

    it 'to the root path' do
      expect(redirect_path).to eq fake_controller.root_path_literal
    end

    it 'with the correct flash message' do
      expect(redirect_options).to have(1).value
      expect(redirect_options[:flash]).to eq(alert: message)
    end
  end # describe 'redirects'
end # shared_examples 'it redirects'
