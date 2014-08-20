# == Schema Information
#
# Table name: user_data
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  email           :string(255)      not null
#  profile         :text
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#  slug            :string(255)
#

# UserData: ActiveRecord persistence and validation for Users.
class UserData < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]
  # attr_accessible :password, :password_confirmation
  has_secure_password
  validates :name,
            uniqueness: true,
            presence: true,
            format: { with: /\A\S+?.+?\S+?\z/ }

  validates :password,
            length: { minimum: 8 },
            allow_nil: true,
            confirmation: true
  validate :verify_no_repeated_spaces_in_name

  # NOTE: Set check_mx to true for production?
  validates_email_format_of :email, check_mx: false

  scope :registered, -> { where 'id > ?', 1 }

  private

  def verify_no_repeated_spaces_in_name
    rebuilt_name = name.to_s.split.join(' ')
    message = 'may not contain adjacent whitespace'
    errors.add :name, message unless name == rebuilt_name
  end
end
