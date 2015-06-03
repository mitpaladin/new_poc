
require 'contracts'
# FIXME: Forced `require_relative`.
require_relative '../../../services/ox_builder'

# Builds a Bootstrap panel with a profile's biodata/"profile" information.
class ProfileBioPanelBuilder
  class Builder < Services::OxBuilder
    include Contracts

    attr_reader :outer_div

    Contract String, Maybe[Proc] => Builder
    def initialize(user_profile)
      super()
      @default_outer_div_class = 'panel panel-default'
      @user_profile = user_profile
      self
    end

    Contract String, Maybe[String] => ELEMENT_TYPE
    def self.build_native(user_profile, css_class = 'panel panel-default')
      Builder.new(user_profile).build do
        outer_div = outer_div_with css_class
        outer_div << panel_heading
        outer_div << wrap_profile
        outer_div
      end
    end

    private

    Contract String => ELEMENT_TYPE
    def outer_div_with(css_class)
      element('div').tap { |el| el[:class] = css_class }
    end

    Contract None => ELEMENT_TYPE
    def panel_heading
      element('div').tap do |ph|
        ph[:class] = 'panel-heading'
        ph << element('h3').tap do |h3|
          h3[:class] = 'panel-title'
          h3 << 'User Profile/Bio Information'
        end
      end # div.panel-heading
    end

    Contract None => ELEMENT_TYPE
    def wrap_profile
      element('div').tap do |pb|
        pb[:class] = 'panel-body'
        pb << parse_profile
      end
    end

    # private

    attr_reader :default_outer_div_class, :user_profile

    # Called from #to_ox > #wrap_profile
    Contract None => ELEMENT_TYPE
    def parse_profile
      Ox.parse user_profile
    rescue Ox::ParseError # no outer/leading element markup; content only
      element('p').tap { |p| p << user_profile }
    end
  end # class ProfileBioPanelBuilder::Builder
end # class ProfileBioPanelBuilder
