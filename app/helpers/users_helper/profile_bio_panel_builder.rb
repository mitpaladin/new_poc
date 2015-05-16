
require 'contracts'

# Builds a Bootstrap panel with a profile's biodata/"profile" information.
class ProfileBioPanelBuilder
  include Contracts

  # FIXME: Apparent bug in shared helper 'a_profile_bio_panel.rb' called from
  #        'profile_bio_panel_builder_spec.rb'.
  FIXME_HELPER = Maybe[RespondTo[:concat, :content_tag]]

  Contract String, FIXME_HELPER => Any
  def initialize(user_profile, h)
    @user_profile, @h = user_profile, h
    self
  end

  Contract None => String
  def to_html
    [
      %(<div class="panel panel-default">),
      %(<div class="panel-heading">),
      %(<h3 class="panel-title">User Profile/Bio Information</h3>),
      %(</div>),  # panel-heading
      %(<div class="panel-body">),
      @user_profile,
      %(</div>),  # panel-body
      %(</div>)   # panel panel-default
    ].join
  end

  protected

  attr_reader :h, :user_profile
end
