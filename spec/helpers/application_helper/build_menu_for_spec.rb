
require 'spec_helper'

describe ApplicationHelper::BuildMenuFor do

  describe :build_menu_for.to_s do

    it 'is a method taking one parameter' do
      p = public_method :build_menu_for
      expect(p).to be_a Method
      expect(p.arity).to eq 1
    end

    describe 'can accept a parameter of the symbol' do

      after :each do
        param = RSpec.current_example.description.to_sym
        expect { build_menu_for param }.to_not raise_error
      end

      it :navbar do
      end

      it :sidebar do
      end
    end # describe 'can accept a parameter of the symbol'

    context 'when called passing in :navbar' do
      let(:built_menu) { build_menu_for :navbar }
      let(:container) { Nokogiri.parse built_menu }

      it 'contains a single (top-level) HTML element' do
        expect(container).to have(1).element
      end

      it 'contains a top-level `ul` element' do
        expect(container.elements.first.name).to eq 'ul'
      end

      describe 'contains a top-level `ul` element that' do
        let(:current_el) { container.elements.first }

        it 'has the "nav" and "navbar-nav" CSS classes' do
          classes = current_el['class'].split
          expect(classes).to include 'nav'
          expect(classes).to include 'navbar-nav'
        end

        it 'contains 6 child elements' do
          expect(current_el).to have(6).children
          # puts "\n***** #{built_menu} *****\n"
        end

        it %w(has as its first child element an `li` element whose only child is
              an `a` element with the text "Home" that links to the root
              path).join(' ') do
          current_li = current_el.children[0]
          expect(current_li.name).to eq 'li'
          expect(current_li).to have(1).children
          a_tag = current_li.children.first
          expect(a_tag.name).to eq 'a'
          expect(a_tag['href']).to eq root_path
          expect(a_tag.text).to eq 'Home'
        end

        it %w(has as its second child element an `li` element whose only child
              is an `a` element with the text "New Post" that links to the
              new-post path).join(' ') do
          current_li = current_el.children[1]
          expect(current_li.name).to eq 'li'
          expect(current_li).to have(1).children
          a_tag = current_li.children.first
          expect(a_tag.name).to eq 'a'
          expect(a_tag['href']).to eq new_post_path
          expect(a_tag.text).to eq 'New Post'
        end

        it %w(has as its third child element an `li` element which serves as a
              horizontal spacer).join(' ') do
          current_li = current_el.children[2]
          expect(current_li.name).to eq 'li'
          expect(current_li.text).to eq '&nbsp;'
          expect(current_li['style']).to eq 'min-width: 3rem;'
          inner_text = current_li.children[0]
          expect(inner_text).to be_text
          expect(inner_text.inner_text).to eq '&nbsp;'
        end

        it %w(has as its fourth child element an `li` element whose only child
              is an `a` element with the text "Sign up" that links to the
              new-user path).join(' ') do
          current_li = current_el.children[3]
          expect(current_li.name).to eq 'li'
          expect(current_li).to have(1).children
          a_tag = current_li.children.first
          expect(a_tag.name).to eq 'a'
          expect(a_tag['href']).to eq new_user_path
          expect(a_tag.text).to eq 'Sign up'
        end

        it %w(has as its fifth child element an `li` element whose only child is
              an `a` element with the text "Log in" that links to the
              new-session path).join(' ') do
          current_li = current_el.children[4]
          expect(current_li.name).to eq 'li'
          expect(current_li).to have(1).children
          a_tag = current_li.children.first
          expect(a_tag.name).to eq 'a'
          expect(a_tag['href']).to eq new_session_path
          expect(a_tag.text).to eq 'Log in'
        end

        it %w(has as its sixth child element an `li` element whose only child is
              an `a` element with the text "Log out" that links to the
              current session path using the HTTP DELETE action, and informs
              search engines not to follow the link).join(' ') do
          current_li = current_el.children[5]
          expect(current_li.name).to eq 'li'
          expect(current_li).to have(1).children
          a_tag = current_li.children.first
          expect(a_tag.name).to eq 'a'
          expect(a_tag['href']).to eq '/sessions/current'
          expect(a_tag['data-method']).to eq 'delete'
          expect(a_tag.text).to eq 'Log out'
        end
      end # describe 'contains a top-level `ul` element that'
    end # context 'when called passing in :navbar'

    context 'when called passing in :sidebar' do
    end # context 'when called passing in :sidebar'

  end # describe :build_menu_for.to_s

end # describe ApplicationHelper::BuildMenuFor
