
shared_examples 'it supports entity initialisation' do
  describe 'supports initialisation' do

    describe 'succeeding' do
      it 'with any combination of valid field names' do
        expect { described_class.new valid_subset }.not_to raise_error
      end

      it 'with invalid field names' do
        expect { described_class.new invalid_attribs }.not_to raise_error
      end
    end # describe 'succeeding'

    describe 'failing' do
      # Null entities aren't very useful. (Use Null Objects instead.)
      it 'with no parameters' do
        message = 'wrong number of arguments (0 for 1)'
        expect { described_class.new }.to raise_error ArgumentError, message
      end
    end # describe 'failing'
  end # describe 'supports initialisation'

  describe 'instantiating with' do

    describe 'valid attribute names' do
      let(:obj) { described_class.new valid_subset }

      it 'sets the attributes' do
        valid_subset.each_pair do |attrib, value|
          expect(obj.send attrib).to eq value
        end
      end
    end # describe 'valid attribute names'

    describe 'valid and invalid attribute names' do
      let(:obj) { described_class.new valid_subset.merge(invalid_attribs) }

      it 'sets the valid attributes' do
        valid_subset.each_pair do |attrib, value|
          expect(obj.send attrib).to eq value
        end
      end

      it 'does not set attributes with invalid names' do
        invalid_attribs.each_key do |attrib|
          message = "`#{attrib}' is not allowed as an instance variable name"
          expect { obj.instance_variable_get attrib }
            .to raise_error NameError, message
        end
      end
    end # describe 'invalid attribute names'
  end # describe 'instantiating with'
end
