
require 'contracts'

require 'current_user_identity'
require_relative '../../services/ox_builder'

require_relative 'profile_bio_header_builder/builder'

# Builds a header element. It contains a button if the named user is logged in.
class ProfileBioHeaderBuilder
  include Contracts

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

  Contract None => Builder::ELEMENT_TYPE
  def native
    Builder.build_native user_name, current_user, h
  end

  private

  attr_reader :h, :user_name

  Contract None => CurrentUserIdentity
  def identity
    @identity ||= CurrentUserIdentity.new(h.session)
  end

  Contract None => RespondTo[:name]
  def current_user
    identity.current_user
  end
end
