
# Support class for #build_body specs.
class MarkupTestBuilder
  attr_reader :builder_name, :caller, :errors

  def initialize(caller_in, builder_name = 'ImageBodyBuilder')
    @caller = caller_in
    @builder_name = 'Entity::Post::' + builder_name
    @errors = []
  end

  def build(source)
    @errors << 'Source and caller differ' unless caller_is?(source)
    bbc = source.send :body_builder_class
    unless bbc.name == builder_name
      @errors << format('Unexpected #body_builder_class "%s"', bbc.name)
    end
    'expected markup'
  end

  def caller_is?(source)
    caller.slug == source.slug && caller.class == source.class
  end
end
