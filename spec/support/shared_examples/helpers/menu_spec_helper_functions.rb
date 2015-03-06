
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

  # Encapsulates parameters for menu-separator helper function below.
  class MenuSeparatorParamValues
    attr_reader :current_el, :index, :style

    def initialize(values_in)
      @index, @current_el, @style = values_in
    end

    def current_li
      current_el.children[index]
    end
  end # class AHBMF::MenuSeparatorParamValues

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

    def menu_separator_item?
      param_values.current_li.text == HTMLEntities.new.decode('&nbsp;')
    end

    def styled_correctly?
      param_values.current_li['style'] == param_values.style
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

  # Validation for menu spacer item content.
  class SpacerInnerTextValidator
    def initialize(param_obj)
      @param_obj = param_obj
    end

    def valid?
      inner_text = param_obj.current_li.children.first
      return false unless inner_text.text?
      inner_text.inner_text == HTMLEntities.new.decode('&nbsp;')
    end

    private

    attr_reader :param_obj
  end # class AHBMF::SpacerInnerTextValidator
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
  h = AHBMF::MenuSeparatorParamValues.new params.values
  v = AHBMF::ParamListItemValidator.new h
  expect(v).to be_list_item_as_indexed_child
  expect(v).to be_menu_separator_item
  expect(v).to be_styled_correctly
  expect(AHBMF::SpacerInnerTextValidator.new h).to be_valid
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
