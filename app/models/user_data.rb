# == Schema Information
#
# Table name: user_data
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  email      :string(255)      not null
#  profile    :text
#  created_at :datetime
#  updated_at :datetime
#

# UserData: ActiveRecord persistence and validation for Users.
class UserData < ActiveRecord::Base
  validates :name,
            uniqueness: true,
            presence: true,
            format: { with: /\A\S+?.+?\S+?/ }
  # NOTE: Set check_mx to true for production?
  validates_email_format_of :email, check_mx: false

  def registered?
    return false unless name.present?
    name != self.class.guest_user_name
  end

  def self.guest_user_name
    'Guest User'
  end
end
