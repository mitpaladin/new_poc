
# Pundit authorisation policy for PostData record instances.
class PostDataPolicy < ApplicationPolicy
  # Filters query results (e.g. PostData#all) based on authorisation policy.
  class Scope < Scope
    def resolve
      public_posts = scope.where.not(pubdate: nil)
      own_drafts = scope.where(pubdate: nil).where(author_name: user.name)
      [public_posts, own_drafts].flatten.sort_by(&:id)
    end
  end # class PostDataPolicy::Scope

  def create?
    # Should return `user.registered?` -- but that's an *entity* concept.
    user.name != user.class.first.name  # reject the Guest User
  end

  def update?
    record.author_name == user.name
  end

  def show?
    return true if record.published?
    record.author_name == user.name
  end
end # class PostDataPolicy
