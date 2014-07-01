
require 'spec_helper'

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

  # FIXME: Repetitive. Clean up w/shared examples or even function(s).
  describe 'compares correctly when' do

    let(:blog2) { blog.clone }
    let(:symbol) { '<=>'.to_sym }

    it 'comparing to an "equal" other' do
      expect(blog.send symbol, blog2).to eq 0
    end

    describe 'the other blog' do

      let(:lower)   { 'titleA' }
      let(:higher)  { 'titleB' }

      after :each do
        allow(blog).to receive(method).and_return @ret1
        allow(blog2).to receive(method).and_return @ret2
        expect(blog.send symbol, blog2).to eq @expected
      end

      describe 'title is' do

        let(:method)  { :title }

        it 'less than this one' do
          @ret1 = higher
          @ret2 = lower
          @expected = 1
        end

        it 'greater than this one' do
          @ret1 = lower
          @ret2 = higher
          @expected = -1
        end
      end # describe 'title is'

      describe 'subtitle is' do

        let(:method)  { :subtitle }

        it 'less than this one' do
          @ret1 = higher
          @ret2 = lower
          @expected = 1
        end

        it 'greater than this one' do
          @ret1 = lower
          @ret2 = higher
          @expected = -1
        end
      end # describe 'subtitle is'

      describe 'has' do
        let(:method) { :entries }

        it 'fewer entries than this one' do
          @ret1 = [nil]
          @ret2 = []
          @expected = 1
        end

        it 'more entries than this one' do
          @ret1 = []
          @ret2 = [nil]
          @expected = -1
        end

        describe "an entry's title that is" do

          let(:e1) { FancyOpenStruct.new title: higher }
          let(:e2) { FancyOpenStruct.new title: lower }

          it 'lower than in this one' do
            @ret1 = [e1]
            @ret2 = [e2]
            @expected = 1
          end

          it 'higher than in this one' do
            @ret1 = [e2]
            @ret2 = [e1]
            @expected = -1
          end
        end # describe "an entry's title that is"

        describe "an entry's body that is" do

          let(:e1) { FancyOpenStruct.new title: 't', body: higher }
          let(:e2) { FancyOpenStruct.new title: 't', body: lower }

          it 'lower than in this one' do
            @ret1 = [e1]
            @ret2 = [e2]
            @expected = 1
          end

          it 'higher than in this one' do
            @ret1 = [e2]
            @ret2 = [e1]
            @expected = -1
          end
        end # describe "an entry's body that is"
      end # describe 'has'
    end # describe 'the other blog'
  end # describe 'compares correctly when'
end # describe Blog
