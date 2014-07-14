
require 'spec_helper'

def it_behaves_like_a_menu_list_item(params)
  text, index, path, current_el, data_method = params.values
  current_li = current_el.children[index]
  expect(current_li.name).to eq 'li'
  expect(current_li).to have(1).children
  a_tag = current_li.children.first
  expect(a_tag.name).to eq 'a'
  expect(a_tag['href']).to eq path
  expect(a_tag['data-method']).to eq data_method if data_method
  expect(a_tag.text).to eq text
end

def it_behaves_like_a_menu_separator(params)
  index, current_el, style = params.values
  current_li = current_el.children[index]
  expect(current_li.name).to eq 'li'
  expect(current_li.text).to eq HTMLEntities.new.decode('&nbsp;')
  expect(current_li['style']).to eq style
  inner_text = current_li.children[0]
  expect(inner_text).to be_text
  expect(inner_text.inner_text).to eq HTMLEntities.new.decode('&nbsp;')
end

shared_examples 'a valid menu of a specified style' do |menu_sym, current_user|
  context "when called passing in :#{menu_sym}" do
    let(:built_menu) { build_menu_for menu_sym, current_user }
    let(:container) { Nokogiri.parse built_menu }
    if menu_sym == :navbar
      nav_style = 'navbar-nav'
      separator_style = 'min-width: 3rem;'
    elsif menu_sym == :sidebar
      nav_style = 'nav-sidebar'
      separator_style = nil
    end

    it 'contains a single (top-level) HTML element' do
      expect(container).to have(1).element
    end

    it 'contains a top-level `ul` element' do
      expect(container.elements.first.name).to eq 'ul'
    end

    describe 'contains a top-level `ul` element that' do
      let(:current_el) { container.elements.first }

      it "has the 'nav' and '#{nav_style}' CSS classes" do
        classes = current_el['class'].split
        expect(classes).to include 'nav'
        expect(classes).to include nav_style
      end

      it 'contains 6 child elements' do
        expect(current_el).to have(6).children
      end

      it %w(has as its first child element an `li` element whose only child is
            an `a` element with the text "Home" that links to the root
            path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'Home',
                                         index: 0,
                                         path: root_path,
                                         current_el: current_el
      end

      it %w(has as its second child element an `li` element whose only child
            is an `a` element with the text "New Post" that links to the
            new-post path).join(' ') do
        it_behaves_like_a_menu_list_item text: 'New Post',
                                         index: 1,
                                         path: new_post_path,
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

      it %w(has as its sixth child element an `li` element whose only child is
            an `a` element with the text "Log out" that links to the
            current session path using the HTTP DELETE action, and informs
            search engines not to follow the link).join(' ') do
        it_behaves_like_a_menu_list_item text: 'Log out',
                                         index: 5,
                                         path: '/sessions/current',
                                         current_el: current_el,
                                         data_method: 'delete'
      end
    end # describe 'contains a top-level `ul` element that'
  end # context "when called passing in :#{menu_sym}"
end # shared_examples 'a valid menu of a specified style'

describe ApplicationHelper::BuildMenuFor do

  describe :build_menu_for.to_s do

    it 'is a method taking two parameters' do
      p = public_method :build_menu_for
      expect(p).to be_a Method
      expect(p.arity).to eq 2
    end

    current_user = UserData.first # Guest User
    it_behaves_like 'a valid menu of a specified style', :navbar, current_user

    it_behaves_like 'a valid menu of a specified style', :sidebar, current_user

  end # describe :build_menu_for.to_s

end # describe ApplicationHelper::BuildMenuFor
