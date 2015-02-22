
shared_examples 'the #initialize method for a Repository' do
  describe 'can be called with' do
    let(:test_factory) do
      Class.new do
      end
    end
    let(:test_dao) do
      Class.new do
      end
    end

    it 'default parameters' do
      expect { described_class.new }.not_to raise_error
    end

    it 'a single "factory" parameter' do
      obj = described_class.new test_factory
      expect(obj.instance_variable_get :@factory).to be test_factory
    end

    it 'two parameters, for "factory" and for "dao"' do
      obj = described_class.new test_factory, test_dao
      expect(obj.instance_variable_get :@dao).to be test_dao
    end
  end # describe 'can be called with'
end # shared_examples do 'the #initialize method for a Repository'
