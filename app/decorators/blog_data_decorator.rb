
# Decorators: Presentation logic based on the model but not part *of* the model.
class BlogDataDecorator < Draper::Decorator
  delegate_all

  def initialize(*)
    super
    @default_entry_count = 10
  end

  def summarise(count = default_entry_count)
    PostData
        .all
        .map(&:decorate)
        .select(&:published?)
        .sort_by(&:pubdate)
        .reverse
        .take(count)
  end

  protected

  attr_reader :default_entry_count
end
