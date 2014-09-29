
shared_examples "entity 'public post' fields" do
  it '"public post" fields' do
    blog = Blog.new.tap { |blog| blog.add_entry entity }
    entity.publish
    impl2 = klass.from_entity entity
    entity2 = klass.to_entity impl2
    expect(entity2.pubdate).to respond_to :to_date  # and is therefore not nil
  end
end
