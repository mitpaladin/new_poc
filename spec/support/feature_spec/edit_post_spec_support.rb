
# Class replaces ~80 lines of set-and-check, set-and-check...
class EditPostSpecSupport
  extend Forwardable

  def initialize(spec)
    @spec = spec
    class_eval do
      def_delegators :@spec, :click_button, :click_link, :fill_in
    end
  end

  def update_and_then_edit_post
    click_edit_button
    update_post_body_with('Updated Body Text')
    verify_page_has_flash_message
    verify_return_to_root_page
    verify_updated_content
    click_edit_button
    verify_on_edit_page
    self
  end

  private

  attr_reader :spec

  def click_edit_button
    click_link button_caption
    self
  end

  def verify_on_edit_page
    spec.instance_eval do
      expect(page).to have_selector '.main > h1', 'Edit Post'
      expect(page).to have_selector '.main > form.edit_post'
    end
    self
  end

  def update_post_body_with(new_body_text)
    @new_body_text = new_body_text
    fill_in 'post_data_body', with: new_body_text
    fill_in 'post_data_image_url', with: ''
    click_button 'Update Post'
    self
  end

  def verify_page_has_flash_message
    expected = "Post '#{post_title}' successfully updated."
    selector = 'div.alert.alert-success.alert-dismissable'
    spec.instance_eval do
      expect(page).to have_selector selector, text: expected
    end
    self
  end

  def verify_return_to_root_page
    slug = post_slug
    caption = button_caption
    spec.instance_eval do
      selector = format('a.btn[href="%s"]', edit_post_path(slug))
      expect(page).to have_selector selector, text: caption
    end
    self
  end

  def verify_updated_content
    new_body_text = @new_body_text
    spec.instance_eval do
      current_content = page.find('.body p').native.content
      expect(current_content).to eq new_body_text
    end
    self
  end

  # Support methods

  def button_caption
    "Edit '#{post_title}'"
  end

  def post_slug
    spec.instance_variable_get :@post_slug
  end

  def post_title
    spec.instance_variable_get :@post_title
  end
end
