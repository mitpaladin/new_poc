
shared_examples "implementation 'saved post' fields" do
  it '"saved post" fields' do
    expect(impl).not_to be_a_new_record
    expect(impl.updated_at).to be_a Time
    expect(impl.updated_at)
        .to be_within(0.5.seconds).of impl.created_at
    expect(impl.slug).to eq post.slug
    expect(impl.id).to be_a Fixnum
    expect(impl.id).to be > 0
  end
end
