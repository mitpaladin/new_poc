
shared_examples "entity 'draft post' fields" do
  it '"draft post" fields' do
    expect(entity.pubdate).to be nil
  end
end
