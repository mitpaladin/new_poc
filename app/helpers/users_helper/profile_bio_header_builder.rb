
require 'contracts'

require 'current_user_identity'

# Builds a header element. It contains a button if the named user is logged in.
class ProfileBioHeaderBuilder
  include Contracts

  Contract String, RespondTo[:concat, :content_tag] => ProfileBioHeaderBuilder
  def initialize(user_name, h)
    @user_name = user_name
    @h = h
    self
  end

  Contract None => String
  def to_html
    h.content_tag :h1, nil, { class: 'bio' }, false do
      h.concat "Profile Page for #{user_name}"
      h.concat make_button
    end
  end

  protected

  attr_reader :h, :user_name

  private

  Contract None => CurrentUserIdentity
  def identity
    @identity ||= CurrentUserIdentity.new(h.session)
  end

  Contract None => RespondTo[:name]
  def current_user
    default = Struct.new(:name).new ''
    return default if identity.guest_user?
    identity.current_user
  end

  Contract None => HashOf[Symbol, String]
  def link_attribs
    {
      class: 'btn btn-xs pull-right',
      href: h.edit_user_path(current_user.slug)
    }
  end

  Contract None => String
  def make_button
    return '' unless current_user.name == user_name
    h.content_tag :a, nil, link_attribs, false do
      'Edit Your Profile'
    end
  end
end
