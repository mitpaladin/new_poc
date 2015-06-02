
require 'contracts'

require 'current_user_identity'

# Builds a header element. It contains a button if the named user is logged in.
class ProfileBioHeaderBuilder
  include Contracts

  ELEMENT_TYPE = Ox::Element

  # :edit_user_path
  HELPER_INPUTS = Contracts::RespondTo[:concat, :content_tag, :session]

  Contract String, HELPER_INPUTS => ProfileBioHeaderBuilder
  def initialize(user_name, h)
    @user_name = user_name
    @h = h
    self
  end

  Contract None => String
  def to_html
    Ox.dump(native).strip
  end

  Contract None => ELEMENT_TYPE
  def native
    title_text = "Profile Page for #{user_name}"
    button = make_button if current_user?
    Services::OxBuilder.new.build do
      element('h1').tap do |h1|
        h1[:class] = 'bio'
        h1 << title_text
        h1 << button if button
      end
    end
  end

  protected

  attr_reader :h, :user_name

  private

  Contract None => CurrentUserIdentity
  def identity
    @identity ||= CurrentUserIdentity.new(h.session)
  end

  Contract None => Bool
  def current_user?
    current_user.name == user_name
  end

  Contract None => RespondTo[:name]
  def current_user
    default = Struct.new(:name).new ''
    return default if identity.guest_user?
    identity.current_user
  end

  Contract None => ELEMENT_TYPE
  def make_button
    ELEMENT_TYPE.new(:a).tap do |a|
      a[:class] = 'btn btn-xs pull-right'
      a[:href] = h.edit_user_path(current_user.slug)
      a << 'Edit Your Profile'
    end
  end
end
