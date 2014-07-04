
shared_examples 'single differing blog field' do |field_sym, v1, v2, extra|
  extra = '' if extra.nil?

  it "#{field_sym} #{extra}".rstrip do
    blog = Blog.new
    blog2 = blog.clone
    allow(blog).to receive(field_sym).and_return v1
    allow(blog2).to receive(field_sym).and_return v2
    expect(blog < blog2).to be true
  end
end # shared_examples
