
# Decorators: Presentation logic based on the model but not part *of* the model.
class BlogDataDecorator < Draper::Decorator
  delegate_all

  def self.policy_class
    BlogDataPolicy
  end
end
