
require_relative '../../sequencer'

module UserHelperSupport
  # Encapsulates/sequences data suitable for user generation.
  class UserCreatorData
    attr_reader :user_password, :user_profile

    def initialize(params_in = {})
      params = default_params.merge params_in
      @user_name = Sequencer.new params[:user_name], params[:name_start]
      @user_email = Sequencer.new params[:user_email], params[:name_start]
      @user_profile = params[:user_profile]
      @user_password = 'password'
    end

    def user_name
      @user_name.to_s
    end

    def user_email
      @user_email.to_s
    end

    def user_profile
      @user_profile.to_s
    end

    def step
      @user_name.step
      @user_email.step
    end

    private

    def default_params
      {
        user_name:    'J Random User %d',
        user_email:   'jruser%d@example.com',
        user_profile: 'Just Another *Random* User',
        name_start:   0
      }
    end
  end # class UserHelperSupport::UserCreatorData
end # module UserHelperSupport
