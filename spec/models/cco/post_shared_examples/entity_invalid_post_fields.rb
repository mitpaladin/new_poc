
shared_examples "entity 'invalid post' fields" do
  it '"invalid post" fields' do
    impl.title = nil
    entity = klass.to_entity impl
    expect(entity).not_to be_valid
  end
end
