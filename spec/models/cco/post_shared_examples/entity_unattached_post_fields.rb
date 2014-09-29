
shared_examples "entity 'unattached post' fields" do
  it '"unattached post" fields' do
    expect(entity.blog).to be nil
  end
end
