# == Schema Information
#
# Table name: post_data
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#  image_url  :string(255)
#

# PostData: ActiveRecord persistence for Posts.
class PostData < ActiveRecord::Base
  # attr_accessor :title, :body # DANGER! DON'T *DO* THIS FOR DB FIELDS!
  validates :title, presence: true
  validate :body_or_image_url?

  private

  def body_or_image_url?
    is_valid = body.to_s.strip.present? || image_url.to_s.strip.present?
    message = 'must be present if image URL is not present'
    errors.add :body, message unless is_valid
  end
end
