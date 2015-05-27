
require 'contracts'

# Builds a Bootstrap panel with a profile's biodata/"profile" information.
class ProfileBioPanelBuilder
  include Contracts

  # FIXME: Apparent bug in shared helper 'a_profile_bio_panel.rb' called from
  #        'profile_bio_panel_builder_spec.rb'.
  FIXME_HELPER = Maybe[RespondTo[:concat, :content_tag]]

  Contract String, FIXME_HELPER => Any
  def initialize(user_profile, h)
    @user_profile = user_profile
    @h = h
    self
  end

  Contract None => Ox::Element
  def to_ox
    Ox::Element.new('div').tap do |outer_div|
      outer_div[:class] = 'panel panel-default'
      outer_div << panel_heading
      outer_div << wrap_profile
    end # outer_div
  end

  Contract None => String
  def to_html
    Ox.default_options = { indent: 0, encoding: 'UTF-8' }
    Ox.dump(to_ox).tr("\n", '')
  end

  private

  Contract None => Ox::Element
  def panel_heading
    Ox::Element.new('div').tap do |ph|
      ph[:class] = 'panel-heading'
      ph << Ox::Element.new('h3').tap do |h3|
        h3[:class] = 'panel-title'
        h3 << 'User Profile/Bio Information'
      end
    end # div.panel-heading
  end

  Contract None => Ox::Element
  def parse_profile
    Ox.parse user_profile
  rescue Ox::ParseError # no outer/leading element markup; content only
    Ox::Element.new('p').tap { |p| p << user_profile }
  end

  Contract None => Ox::Element
  def wrap_profile
    Ox::Element.new('div').tap do |pb|
      pb[:class] = 'panel-body'
      pb << parse_profile
    end
  end

  attr_reader :h, :user_profile
end
