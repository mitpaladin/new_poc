
shared_examples 'Post field comparison' do |field_sym, values|
  values ||= { higher: 'string2', lower: 'string1' }

  it "compares two posts correctly when their :#{field_sym} field differs" do
    assign_sym = "#{field_sym}=".to_sym
    post = Post.new FactoryGirl.attributes_for(:post_datum)
    post2 = Marshal.load(Marshal.dump post)

    post.send assign_sym, values[:lower]
    post2.send assign_sym, values[:higher]
    expect(post2 > post).to be true
  end
end # shared_examples
