
shared_examples "entity 'saved post' fields" do
  it '"new post" fields' do
    expect(entity.slug).to eq entity.title.parameterize
  end
end
