
# Data-access bag-of-fields object for posts. See Issue #111.
class PostDao < ActiveRecord::Base
  self.table_name = 'posts'
  extend FriendlyId

  validates :title, presence: true # Slugs are unique so titles need not be.
  # other :use options we might investigate: :scoped, :simple_i18n, :history
  friendly_id :slug_candidates, use: [:slugged, :finders]
  validates :author_name, presence: true

  scope :authored_by, -> (user_name) { where 'author_name = ?', user_name }

  def slug_candidates
    [
      :title,
      [:title, :author_name]
    ]
  end
end # class PostDao
