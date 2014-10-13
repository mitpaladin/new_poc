
shared_examples "implementation 'public post' fields" do
  it '"public post" fields' do
    expect(impl.pubdate).to be_a Time
  end
end
