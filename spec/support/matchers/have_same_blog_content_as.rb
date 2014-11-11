
RSpec::Matchers.define :have_same_blog_content_as do |other_blog|

  match do |actual_blog|
    if other_blog == actual_blog
      true
    else
      verifier = MatcherSupport::BasicAttributeVerifier
                 .new(actual_blog, other_blog).run
      if verifier.valid?
        MatcherSupport::BlogEntryMatcher.new(actual_blog, other_blog).run
      else
        @reasons = verifier.messages
        false
      end
    end
  end

  description do
    'have the same title and subtitle, the same number of entries, and the' \
        'same title and body for each corresponding entry in two blogs.'
  end

  failure_message do
    'Expected two blogs to have identical content, but ' +
      @reasons.join('; and ')
  end
end
