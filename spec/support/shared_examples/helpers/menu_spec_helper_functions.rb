
# Helper functions for ApplicationHelper#build_menu_for specs.

# rubocop:disable Metrics/AbcSize
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
# rubocop:enable Metrics/AbcSize

def separator_style_for(menu_sym)
  if menu_sym == :navbar
    'min-width: 3rem;'
  else
    nil
  end
end

def user_type_name_for(current_user)
  if current_user.name == 'Guest User'
    current_user.name
  else
    'Registered User'
  end
end
