
require 'spec_helper'

require 'support/shared_examples/models/blog/single_differing_blog_field'

def build_example_posts(entry_count = 10)
  posts = []
  attr_list = FactoryGirl.attributes_for_list :post_datum, entry_count
  attr_list.each { |post_attribs| posts << Post.new(post_attribs) }
  posts
end

describe Blog do

  subject(:blog) { Blog.new }
  let(:default_title) { 'Watching Paint Dry' }
  let(:default_subtitle) do
    'The trusted source for drying paint news and opinion'
  end

  describe 'has an initialiser that' do
    it 'accepts one optional parameter' do
      p = Blog.method :new
      # A value of 1 means "1 required param", with -1 as "one optional param"
      expect(p.arity).to eq(-1)
    end

    context 'when no parameters are passed to the initializer' do

      it 'has the default value for the blog title' do
        expect(blog.title).to eq default_title
      end

      it 'has the default value for the blog subtitle' do
        expect(blog.subtitle).to eq default_subtitle
      end
    end # context 'when no parameters are passed to the initializer'

    context 'when a parameter Hash is passed to the initialiser' do
      let(:title) { 'Some Blog Title' }
      let(:subtitle) { 'Some Subtitle Or Other' }
      let(:blog) { Blog.new title: title, subtitle: subtitle }

      it 'has the specified value for the blog title' do
        expect(blog.title).to eq title
      end

      it 'has the specified value for the blog subtitle' do
        expect(blog.subtitle).to eq subtitle
      end
    end # context 'when a parameter Hash is passed to the initialiser'
  end # describe 'has an initialiser that'

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
        FactoryGirl.attributes_for_list :post_datum, titles.count do |attribs|
          attribs[:title] = titles.shift
          blog.add_entry(blog.new_post attribs)
        end
        mangled = blog.sort.map { |e| e.title.upcase }
        expect(mangled).to eq %w(CADILLAC BLUE GREEN PINK RED)
      end
    end # context 'for a collection of unpublished posts'

    context 'for a collection of published posts' do

      it 'allows the Blog to be iterated as a collection of Posts by date' do
        data = [
          ['Terrible Tuesday', Chronic.parse('17 December 2030')],
          ['Magic Monday', Chronic.parse('16 Dec 2030')],
          ['Ready for Thursday?', Chronic.parse('19th of December, 2030')],
          ['Welcome to Wednesday', Chronic.parse('18 December 2030')],
          ['Finally Friday', Chronic.parse('Dec 20, 3030')]
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
        actual = blog.sort.map(&:title)
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
