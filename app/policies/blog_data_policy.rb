
# Pundit authorisation policy for BlogData record instances.
class BlogDataPolicy < ApplicationPolicy
  def index?
    true  # anybody can view the blog index
  end
  alias_method :show?, :index?
end # class PostDataPolicy
