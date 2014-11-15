
shared_support_dir = 'support/shared_examples/helpers/'
require shared_support_dir + 'valid_menu_for_guest_or_registered_user'
require shared_support_dir + 'registered_user_menu_items'

description = 'a valid menu for a Registered User, of a specified style'
shared_examples description do |menu_sym, current_user|
  current_user = UserEntity.new FactoryGirl.attributes_for(:user, :saved_user)

  it_behaves_like 'a valid menu for either a Guest or Registered User',
                  current_user,
                  menu_sym

  it_behaves_like 'a menu containing appropriate items for a Registered User',
                  current_user,
                  menu_sym
end # shared_examples 'a valid menu for a Registered User, of a specified style'
