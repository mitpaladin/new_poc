
shared_examples 'a form-attributes helper' do |form_name|
  describe ":#{form_name}_form_attributes" do
    it 'returns a Hash' do
      expect(subject).to be_a Hash
    end

    describe 'has top-level keys for' do
      [:html, :role, :url].each do |key|
        it ":#{key}" do
          expect(subject).to have_key key
        end
      end
    end # describe 'has top-level keys for'

    describe 'has an :html sub-hash that contains the correct values for' do
      it 'the :id key' do
        expect(subject[:html][:id]).to eq form_name
      end

      it 'the :class key' do
        classes = subject[:html][:class].split(/\s+/)
        expect(classes).to include 'form-horizontal'
        expect(classes).to include form_name
      end
    end # describe 'has an :html sub-hash that contains the correct values for'

    it 'has a :role item with the value "form" as an ARIA instruction' do
      expect(subject[:role]).to eq 'form'
    end
  end # describe ":#{form_name}_form_attributes"
end
