
require 'support/shared_examples/helpers/menu_spec_helper_functions'

description = 'a menu containing appropriate items for a Guest User'
shared_examples description do |current_user, menu_sym|

  context "when called passing in :#{menu_sym} for a Guest User" do
    let(:built_menu) { build_menu_for menu_sym, current_user }
    let(:container) { Nokogiri.parse built_menu }
    separator_style = separator_style_for menu_sym

    describe 'contains a top-level `ul` element that' do
      let(:current_el) { container.elements.first }

      it 'contains 5 child elements' do
        expect(current_el).to have(5).children
      end

      it %w(has as its first child element an `li` element whose only child is
            an `a` element with the text "Home" that links to the root
            path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'Home',
                                         index: 0,
                                         path: root_path,
                                         current_el: current_el
      end

      it %w(has as its second child element an `li` element whose only child is
            an `a` element with the text "All members" that links to the
            user-index path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'All members',
                                         index: 1,
                                         path: users_path,
                                         current_el: current_el
      end

      it %w(has as its third child element an `li` element which serves as a
            vertical spacer).join(' ') do
        it_behaves_like_a_menu_separator index: 2,
                                         current_el: current_el,
                                         style: separator_style
      end

      it %w(has as its fourth child element an `li` element whose only child
            is an `a` element with the text "Sign up" that links to the
            new-user path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'Sign up',
                                         index: 3,
                                         path: new_user_path,
                                         current_el: current_el
      end

      it %w(has as its fifth child element an `li` element whose only child is
            an `a` element with the text "Log in" that links to the
            new-session path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'Log in',
                                         index: 4,
                                         path: new_session_path,
                                         current_el: current_el
      end

    end # describe 'contains a top-level `ul` element that'
  end # context "when called passing in :#{menu_sym} for a Guest User"
end # shared_examples 'a menu containing appropriate items for a Guest User'
