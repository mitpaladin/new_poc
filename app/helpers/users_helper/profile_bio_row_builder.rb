
# Builds a Bootstrap-styled "row" with a panel containing profile/"biodata" text
# for a user.
class ProfileBioRowBuilder
  def initialize(user_name, user_profile, h)
    @user_name, @user_profile, @h = user_name, user_profile, h
  end

  def to_html
    h.content_tag :div, nil, { class: 'row' }, false do
      h.concat build_profile_heading
      h.concat ProfileBioPanelBuilder.new(user_profile, h).to_html
    end
  end

  protected

  attr_reader :h, :user_name, :user_profile

  private

  def build_profile_heading
    h.content_tag :h1 do
      "Profile Page for #{user_name}"
    end
  end
end
