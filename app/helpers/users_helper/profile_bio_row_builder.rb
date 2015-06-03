
require 'contracts'

# Builds a Bootstrap-styled "row" with a panel containing profile/"biodata" text
# for a user.
class ProfileBioRowBuilder
  include Contracts

  HELPER_CONTRACT = RespondTo[:concat, :content_tag]

  Contract String, String, HELPER_CONTRACT => ProfileBioRowBuilder
  def initialize(user_name, user_profile, h)
    @user_name = user_name
    @user_profile = user_profile
    @h = h
    self
  end

  Contract None => String
  def to_html
    reformat_html_output Ox.dump(native)
  end

  protected

  attr_reader :h, :user_name, :user_profile

  private

  ELEMENT_TYPE = Ox::Element

  Contract None => ELEMENT_TYPE
  def native
    outer_container do |div|
      div['class'] = 'row'
      div << ProfileBioHeaderBuilder.new(user_name, h).native
      div << ProfileBioPanelBuilder.new(user_profile).native
    end
  end

  Contract Proc => ELEMENT_TYPE
  def outer_container
    ELEMENT_TYPE.new('div').tap { |div| yield div }
  end

  Contract String => String
  def reformat_html_output(markup)
    markup.tr "\n", ''
  end
end
