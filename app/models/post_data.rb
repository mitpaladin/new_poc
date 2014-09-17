# == Schema Information
#
# Table name: post_data
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#  image_url   :string(255)
#  pubdate     :datetime
#  author_name :string(255)
#  slug        :string(255)
#

# PostData: ActiveRecord persistence for Posts.
class PostData < ActiveRecord::Base
  extend FriendlyId
  # attr_accessor :title, :body # DANGER! DON'T *DO* THIS FOR DB FIELDS!
  # `status` is apparently a method inherited from ActiveRecord...
  attr_accessor :post_status
  validates :title, presence: true # Slugs are unique so titles need not be.
  # other :use options we might investigate: :scoped, :simple_i18n, :history
  friendly_id :slug_candidates, use: [:slugged, :finders]
  validates :author_name, presence: true
  validate :body_or_image_url?

  def slug_candidates
    [
      :title,
      [:title, :author_name]
    ]
  end

  scope :authored_by, -> (user_name) { where 'author_name = ?', user_name }

  private

  def body_or_image_url?
    is_valid = body.to_s.strip.present? || image_url.to_s.strip.present?
    message = 'must be present if image URL is not present'
    errors.add :body, message unless is_valid
  end
end
