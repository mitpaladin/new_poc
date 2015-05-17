
require 'spec_helper'

shared_support_dir = 'support/shared_examples/helpers/'
require shared_support_dir + 'valid_menu_for_guest_user'
require shared_support_dir + 'valid_menu_for_registered_user'

describe ApplicationHelper::BuildMenuFor do
  describe :build_menu_for.to_s do
    context 'for a Guest User' do
      this_shared_example = %w(a valid menu for a Guest User, of a specified
                               style).join ' '
      it_behaves_like this_shared_example, :navbar

      it_behaves_like this_shared_example, :sidebar
    end # context 'for a Guest User'

    context 'for a Registered User' do
      this_shared_example = %w(a valid menu for a Registered User, of a
                               specified style).join ' '

      it_behaves_like this_shared_example, :navbar

      it_behaves_like this_shared_example, :sidebar
    end # context 'for a Registered User
  end # describe :build_menu_for.to_s
end # describe ApplicationHelper::BuildMenuFor
