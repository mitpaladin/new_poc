
shared_examples "entity 'new post' fields" do
  it '"new post" fields' do
    expect(entity.slug).to be nil
  end
end
