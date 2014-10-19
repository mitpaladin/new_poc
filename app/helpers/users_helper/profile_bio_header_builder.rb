
require 'current_user_identity'

# Builds a header element. It contains a button if the named user is logged in.
class ProfileBioHeaderBuilder
  def initialize(user_name, h)
    @user_name, @h = user_name, h
  end

  def to_html
    h.content_tag :h1, nil, { class: 'bio' }, false do
      h.concat "Profile Page for #{user_name}"
      h.concat make_button
    end
  end

  protected

  attr_reader :h, :user_name

  private

  def identity
    @identity ||= CurrentUserIdentity.new(h.session)
  end

  def current_user
    default = Struct.new(:name).new ''
    return default if identity.guest_user?
    identity.current_user
  end

  def make_button
    return '' unless current_user.name == user_name
    attribs = { class: 'btn btn-xs pull-right', type: 'button' }
    attribs[:href] = h.edit_user_path(current_user.slug)
    h.content_tag :button, nil, attribs, false do
      'Edit Your Profile'
    end
  end
end
