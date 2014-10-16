
shared_examples 'a StoreResult with a Guest User entity' do
  describe 'an :entity field matching the Guest User settings for' do
    let(:entity) { result.entity }

    it 'name' do
      expect(entity.name).to eq 'Guest User'
    end

    it 'dummy password for testing' do
      expect(entity.password).to eq 'password'
      expect(entity.password_confirmation).to eq entity.password
    end

    it 'slug' do
      expect(entity.slug).to eq 'guest-user'
    end
  end # describe 'an :entity field matching the Guest User settings for'
end # shared_examples 'a StoreResult with a Guest User entity'
