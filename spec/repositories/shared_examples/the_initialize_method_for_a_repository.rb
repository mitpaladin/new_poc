
shared_examples 'the #initialize method for a Repository' do
  describe 'can be called with' do
    it 'default parameters' do
      expect { klass.new }.not_to raise_error
    end

    it 'a single "factory" parameter' do
      obj = klass.new :test_factory
      expect(obj.instance_variable_get :@factory).to be :test_factory
    end

    it 'two parameters, for "factory" and for "dao"' do
      obj = klass.new :test_factory, :test_dao
      expect(obj.instance_variable_get :@dao).to be :test_dao
    end
  end # describe 'can be called with'
end # shared_examples do 'the #initialize method for a Repository'
