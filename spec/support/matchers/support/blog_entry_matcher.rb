
module MatcherSupport
  # Class that compares lists of entries (posts) within two blogs. Called
  # directly by matcher.
  class BlogEntryMatcher
    attr_reader :actual_blog, :other_blog

    def initialize(actual_blog, other_blog)
      @actual_blog = actual_blog
      @other_blog = other_blog
    end

    def run
      ret = true
      actual_blog.entries.each_with_index do |entry, index|
        ret &&= entry.title == other_blog.entries[index].title
        ret &&= entry.body == other_blog.entries[index].title
      end
      ret
    end
  end
end # module MatcherSupport
