
# Feature-spec support class to create and log in with a new user.
class FeatureSpecLoginHelper
  def initialize(spec_obj)
    @s = spec_obj
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
  end

  protected

  attr_reader :s

  private

  def click_sign_up_navbar_link
    s.instance_eval do
      visit root_path
      within(:css, 'ul.navbar-nav') do
        click_link 'Sign up'
      end
    end
  end

  def setup_user_fields
    s.instance_eval do
      @user_bio =       'I am what I am. You are what you eat.'
      @user_email =     'jruser@example.com'
      @user_name =      'J Random User'
      @user_password =  's00persecret'
    end
  end
end
