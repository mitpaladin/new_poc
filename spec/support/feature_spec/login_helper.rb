
require_relative 'helper_base'
require_relative 'user_helper_support/user_creator_data'

# Feature-spec support class to create and log in with a new user.
class FeatureSpecLoginHelper < FeatureSpecHelperBase
  extend Forwardable
  attr_accessor :data
  def_delegator :@data, :step, :step

  def initialize(spec_obj, data = UserHelperSupport::UserCreatorData.new)
    super
  end

  def register_and_login
    register
    login
  end

  def register
    setup_user_fields
    click_sign_up_navbar_link
    s.instance_eval do
      fill_in 'Name', with: @user_name
      fill_in 'Email', with: @user_email
      fill_in 'Password', with: @user_password
      fill_in 'Password confirmation', with: @user_password
      fill_in 'Profile Summary (Optional)', with: @user_bio
      click_button 'Sign Up'
    end
  end

  def login
    setup_user_fields
    s.instance_eval do
      within(:css, 'ul.navbar-nav') do
        click_link 'Log in'
      end
      fill_in 'Name', with: @user_name
      fill_in 'Password', with: @user_password
      click_button 'Log In'
    end
  end

  def logout
    s.instance_eval do
      within(:css, 'ul.navbar-nav') do
        click_link 'Log out'
      end
    end
    clear_user_fields
  end

  private

  def click_sign_up_navbar_link
    s.instance_eval do
      visit root_path
      within(:css, 'ul.navbar-nav') do
        click_link 'Sign up'
      end
    end
  end

  def clear_user_fields
    s.instance_eval do
      @user_bio = nil
      @user_email = nil
      @user_name = nil
      @user_password = nil
    end
  end

  def setup_user_fields
    s.instance_exec(data) do |data|
      @user_bio =         data.user_profile
      @user_email =       data.user_email
      @user_name =        data.user_name
      @user_password =    data.user_password
    end
  end
end
