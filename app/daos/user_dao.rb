
# Data-access bag-of-fields object for users. See Issue #111.
class UserDao < ActiveRecord::Base
  self.table_name = 'users'
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  has_secure_password
  validates :name,
            uniqueness: true,
            presence: true,
            format: { with: /\A\S+?.+?\S+?\z/ }

  validates :password,
            length: { minimum: 8 },
            allow_nil: true,
            confirmation: true

  validates :slug, uniqueness: true, presence: true

  # NOTE: Set check_mx to true for production?
  validates_email_format_of :email, check_mx: false

  # Do *NOT* include the Guest User in queries using '#all'
  def all
    self.class.where 'name != ?', 'Guest User'
  end
end # class UserDao
