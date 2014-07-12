
module DSO
  # Create a new user, isolating the caller (which is normally the controller)
  # from any knowledge of exactly how that happens.
  class PermissiveUserCreator < ActiveInteraction::Base
    hash :user_data, default: {} do
      string :name, default: '', strip: true
      string :email, default: '', strip: true
      string :profile, default: '', strip: true
      string :password, default: '', strip: true
      string :password_confirmation, default: '', strip: true
    end

    def execute
      UserData.new user_data
    end
  end
end # module DSO
