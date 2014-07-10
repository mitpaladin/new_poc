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
            format: { with: /\A\S+?.+?\S+?\z/ }

  validate :verify_no_repeated_spaces_in_name

  # NOTE: Set check_mx to true for production?
  validates_email_format_of :email, check_mx: false

  private

  def verify_no_repeated_spaces_in_name
    rebuilt_name = name.to_s.split.join(' ')
    message = 'may not contain adjacent whitespace'
    errors.add :name, message unless name == rebuilt_name
  end
end
