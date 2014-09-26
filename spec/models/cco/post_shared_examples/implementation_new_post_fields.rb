
shared_examples "implementation 'new post' fields" do
  it '"new post" fields' do
    expect(impl).to be_a_new_record
    expect(impl.updated_at).to be nil
    expect(impl.slug).to be_nil
    expect(impl.id).to be nil
  end
end
