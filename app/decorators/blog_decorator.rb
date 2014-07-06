
# Decorators: Presentation logic based on the model but not part *of* the model.
class BlogDecorator < Draper::Decorator
  delegate_all

  def initialize(*)
    super
    @default_entry_count = 10
  end

  def summarise(count = default_entry_count)
    entries.select { |post| post.published? }.sort.reverse.take(count)
  end

  protected

  attr_reader :default_entry_count
end
