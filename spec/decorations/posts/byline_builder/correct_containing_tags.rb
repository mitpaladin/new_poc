
shared_examples 'it has correct containing tags' do
  it 'which is a :p tag pair wrapping a :time tag pair' do
    expect(actual).to match %r{<p><time.*>.+</time></p>}
  end

  it 'has an attribute value of "pubdate" for the :time tag :pubdate' do
    expect(actual).to match %r{<time pubdate="pubdate">.+</time>}
  end
end
