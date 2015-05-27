
require 'contracts'

class OxBuilder
  include Contracts

  Contract Maybe[Proc] => OxBuilder
  def initialize
    Ox.default_options = { indent: 0, encoding: 'UTF-8' }
    self
  end

  Contract None => String
  def dump
    Ox.dump doc
  end

  private

  Contract String, Maybe[Proc] => Ox::Element
  def element(name)
    Ox::Element.new(name).tap { |ret| yield ret if block_given? }
  end

  Contract String, String => Ox::Element
  def link_to(text, url)
    element('a').tap do |elem|
      elem[:href] = url
      elem << text
    end
  end

  Contract None => Ox::Document
  def doc
    @doc ||= new_doc
  end

  Contract None => Ox::Document
  def new_doc
    Ox::Document.new
  end
end # class OxBuilder

# Builds a Bootstrap panel with a profile's biodata/"profile" information.
class ProfileBioPanelBuilder
  class Builder < OxBuilder
    include Contracts

    attr_reader :outer_div

    Contract String, Maybe[Proc] => Builder
    def initialize(user_profile)
      super()
      @default_outer_div_class = 'panel panel-default'
      @user_profile = user_profile
      self
    end

    Contract Maybe[String] => Builder
    def build_outer_div(css_class = default_outer_div_class)
      @outer_div = element('div').tap do |el|
        el[:class] = css_class
      end
      self
    end

    Contract None => Builder
    def build_panel_heading
      @outer_div << panel_heading
      self
    end

    Contract None => Builder
    def build_profile
      @outer_div << wrap_profile
      self
    end

    private

    Contract None => Ox::Element
    def panel_heading
      element('div').tap do |ph|
        ph[:class] = 'panel-heading'
        ph << element('h3').tap do |h3|
          h3[:class] = 'panel-title'
          h3 << 'User Profile/Bio Information'
        end
      end # div.panel-heading
    end

    Contract None => Ox::Element
    def wrap_profile
      element('div').tap do |pb|
        pb[:class] = 'panel-body'
        pb << parse_profile
      end
    end

    # private

    attr_reader :default_outer_div_class, :user_profile

    # Called from #to_ox > #wrap_profile
    Contract None => Ox::Element
    def parse_profile
      Ox.parse user_profile
    rescue Ox::ParseError # no outer/leading element markup; content only
      element('p').tap { |p| p << user_profile }
    end
  end # class Builder

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

  Contract None => String
  def to_html
    Ox.dump(to_ox).tr("\n", '')
  end

  private

  attr_reader :h, :user_profile

  Contract None => Ox::Element
  def to_ox
    Builder.new(user_profile)
      .build_outer_div.build_panel_heading.build_profile.outer_div
  end
end
