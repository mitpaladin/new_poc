
RSpec::Matchers.define :be_saved_post_entity_for do |source|
  match do |actual|
    attrs = [
      :author_name,
      :body,
      :image_url,
      :pubdate,
      :slug,
      :title
    ]
    @reasons = SavedEntityVerifier.new(source, actual) do
      required_in_both(*attrs)
      verify
    end.reasons
    @reasons.empty?
  end

  description do
    %(have the same author name, body, image_url, pubdate, slug and title
      fields).squeeze
  end

  failure_message do
    %(Expected a source and target(post-save) entity to #{description}, but ) +
      @reasons.join('; and ')
  end
end # RSpec::Matchers.define :be_saved_post_entity_for
