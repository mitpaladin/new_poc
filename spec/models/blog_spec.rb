
require 'spec_helper'

require 'support/shared_examples/models/blog/single_differing_blog_field'

def build_example_posts(entry_count = 10)
  posts = []
  entry_count.times do
    posts << Post.new(FactoryGirl.attributes_for :post_datum)
  end
  posts
end

describe Blog do

  subject(:blog) { Blog.new }

  it 'has an initialiser that accepts no arguments' do
    expect { Blog.new nil }
        .to raise_error ArgumentError, 'wrong number of arguments (1 for 0)'
  end

  describe 'has accessors for' do

    # "title" and "subtitle" are now delegated

    describe 'an "entries" attribute that is' do

      it 'array-like Enumerable' do
        expect(blog.entries).to respond_to :[]
        expect(blog.entries).to be_an Enumerable
      end

      it 'initially empty' do
        expect(blog.entries).to be_empty
      end
    end # describe 'an "entries" attribute that is'
  end # describe 'has accessors for'

  describe :add_entry do

    it 'adds the entry to the blog' do
      entry = FancyOpenStruct.new title: 'title', body: 'body'
      blog.add_entry entry
      expect(blog.entry? entry).to be true
    end
  end # describe :add_entry

  describe :each do

    context 'for a collection of unpublished posts' do

      it 'allows the Blog to be iterated as a collection of Posts by title' do
        titles = %w(red green blue pink Cadillac)
        titles.each do |title|
          attribs = FactoryGirl.attributes_for :post_datum, title: title
          blog.add_entry(blog.new_post attribs)
        end
        mangled = blog.sort.map { |e| e.title.upcase }
        expected = %w(CADILLAC BLUE GREEN PINK RED)
        expect(mangled).to eq expected
      end
    end # context 'for a collection of unpublished posts'

    context 'for a collection of published posts' do

      it 'allows the Blog to be iterated as a collection of Posts by date' do
        data = [
          ['Terrible Tuesday', Chronic.parse('last Tuesday at 9 AM')],
          ['Magic Monday', Chronic.parse('last Monday at 8 AM')],
          ['Ready for Thursday?', Chronic.parse('last Thursday at noon')],
          ['Welcome to Wednesday', Chronic.parse('last Wednesday at 2 PM')],
          ['Finally Friday', Chronic.parse('last Friday at 6 PM')]
        ]
        data.each do |item|
          attribs = FactoryGirl.attributes_for :post_datum, title: item[0]
          post = blog.new_post attribs
          post.publish item[1]
        end
        expected_titles = [
          'Magic Monday',
          'Terrible Tuesday',
          'Welcome to Wednesday',
          'Ready for Thursday?',
          'Finally Friday'
        ]
        actual = blog.sort.map { |entry| entry.title }
        expect(actual).to eq expected_titles
      end
    end # context 'for a collection of published posts'
  end # describe :each

  describe :entries do
    let(:entry_count) { 10 }

    before :each do
      posts = FactoryGirl.build_list :post_datum, entry_count
      # Setting a Post's `@blog` attribute to the blog entity is done in the
      # `Blog#add_entry` method. An argument could be made that this *should* be
      # the CCO's job, or that the CCO should set the entity's `@blog` attribute
      # to something *other than* the underlying `BlogData` instance, but Oh
      # Well...
      posts.each { |post| blog.add_entry(CCO::PostCCO.to_entity post) }
    end

    it 'returns a collection with the correct number of entries' do
      expect(blog.entries).to have(entry_count).entries
    end

    it 'has the correct ordering of entries' do
      title_pattern = /Test Title Number (\d+)/
      title_format  = 'Test Title Number %d'
      first_index = blog.entries.first.title.match(title_pattern)[1].to_i
      blog.entries.each_with_index do |_post, index|
        expected = format title_format, first_index + index
        expect(blog.entries[index].title).to eq expected
      end
    end
  end # describe :entries

  describe :new_post do

    before :each do
      @new_post = OpenStruct.new
      blog.post_source = -> { @new_post }
    end

    it 'returns a new post' do
      expect(blog.new_post).to be @new_post
    end

    it "sets the post's blog reference to itself" do
      expect(blog.new_post.blog).to be blog
    end

    it 'accepts an attribute hash on behalf of the post maker' do
      post_source = double 'post_source'
      params_in = { x: 42, y: 'z' }
      expect(post_source).to receive(:call)
          .with(params_in).and_return @new_post
      blog.post_source = post_source
      blog.new_post x: 42, y: 'z'
    end
  end # describe :new_post

  describe 'compares correctly when' do

    let(:blog2) { blog.clone }

    it 'comparing to an "equal" other' do
      expect(blog == blog2).to be true
    end

    describe 'the two blogs differ only in their' do

      it_behaves_like 'single differing blog field', :title, 'title1', 'title2'

      it_behaves_like 'single differing blog field', :subtitle, 'sub1', 'sub2'

      describe :entries do

        it_behaves_like 'single differing blog field',
                        :entries,
                        [],
                        build_example_posts,
                        'with only the second blog having entries'

        it_behaves_like 'single differing blog field',
                        :entries,
                        build_example_posts,
                        build_example_posts,
                        'with the same number of different entries in each'
      end # describe :entries
    end # describe 'the two blogs differ only in their'
  end # describe 'compares correctly when'

  describe 'will not add a Post to itself multiple times' do

    it 'through calling #publish after #add_entry' do
      attribs = FactoryGirl.attributes_for :post_datum
      post = blog.new_post attribs
      # OK, we've "edited a draft" -- save it
      blog.add_entry post
      # And, some time later, we've finished editing. Publication time!
      post.publish
      # Now... is the post in `entries` more than once?
      expect(blog.entries.rindex post).to eq blog.entries.index(post)
    end
  end # describe 'will not add a Post to itself multiple times'
end # describe Blog
