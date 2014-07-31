
# Builds a Bootstrap panel with a profile's biodata/"profile" information.
class ProfileBioPanelBuilder
  def initialize(user_profile, h)
    @user_profile, @h = user_profile, h
  end

  def to_html
    h.content_tag :div, nil, { class: 'panel panel-default' }, false do
      h.concat build_panel_heading
      h.concat build_panel_body
    end
  end

  protected

  attr_reader :h, :user_profile

  private

  def build_panel_body
    h.content_tag :div, nil, { class: 'panel-body' }, false do
      user_profile
    end
  end

  def build_panel_heading
    h.content_tag :div, nil, { class: 'panel-heading' }, false do
      h.concat build_panel_title
    end
  end

  def build_panel_title
    h.content_tag :h3, nil, { class: 'panel-title' }, false do
      'User Profile/Bio Information'
    end
  end
end
