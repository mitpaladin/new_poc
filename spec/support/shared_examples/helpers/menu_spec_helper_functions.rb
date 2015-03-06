
# Helper functions for ApplicationHelper#build_menu_for specs.
module AHBMF
  # Encapsulates parameters for helper function, and derived properties.
  class ParamValues
    attr_reader :current_el, :data_method, :index, :path, :text

    def initialize(values_in)
      @text, @index, @path, @current_el, @data_method = values_in
    end

    def current_li
      current_el.children[index]
    end

    def current_a_tag
      current_li.children.first
    end
  end # class AHBMF::ParamValues

  # Helper-function list-item validation for the two following functions.
  class ParamListItemValidator
    def initialize(param_values)
      @param_values = param_values
    end

    def indexed_child_with_one_child?
      param_values.current_li.children.length == 1
    end

    def list_item_as_indexed_child?
      param_values.current_li.name == 'li'
    end

    private

    attr_reader :param_values
  end # class AHBMF::ParamListItemValidator

  # Helper-function anchor-tag validation for the two following functions.
  class ParamAnchorTagValidator
    def initialize(param_obj)
      @param_obj = param_obj
    end

    def with_correct_data_method?
      return true unless param_obj.data_method
      a_tag['data-method'] == param_obj.data_method
    end

    def with_correct_href_path?
      a_tag['href'] == param_obj.path
    end

    def with_correct_tag_name?
      a_tag.name == 'a'
    end

    def with_correct_text?
      a_tag.text == param_obj.text
    end

    private

    def a_tag
      param_obj.current_a_tag
    end

    attr_reader :param_obj
  end # class AHBMF::ParamAnchorTagValidator
end # module AHBMF

def it_behaves_like_a_menu_list_item(params)
  h = AHBMF::ParamValues.new params.values
  v = AHBMF::ParamListItemValidator.new h
  expect(v).to be_list_item_as_indexed_child
  expect(v).to be_indexed_child_with_one_child
  v = AHBMF::ParamAnchorTagValidator.new h
  expect(v).to be_with_correct_tag_name
  expect(v).to be_with_correct_href_path
  expect(v).to be_with_correct_data_method
  expect(v).to be_with_correct_text
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

def separator_style_for(menu_sym)
  return 'min-width: 3rem;' if menu_sym == :navbar
end

def user_type_name_for(current_user)
  if current_user.name == 'Guest User'
    current_user.name
  else
    'Registered User'
  end
end
