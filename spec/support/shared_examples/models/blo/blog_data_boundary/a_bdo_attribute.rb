
shared_examples 'a BDO attribute' do |type_desc, name_sym, is_valid|
  if type_desc == 'array-like'
    type_sym = :[]
  else
    type_sym = :to_s
  end
  valid_desc = is_valid.to_s.split('?').first

  describe "a '#{name_sym}' that is" do
    let(:value) { blog_data.send name_sym }

    it type_desc do
      expect(value).to respond_to type_sym
    end

    it "is #{valid_desc}" do
      expect(value.send is_valid).to be true
    end
  end # describe "a '#{name}' that is"
end
