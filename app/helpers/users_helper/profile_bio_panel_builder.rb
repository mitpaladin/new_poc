
require 'contracts'

require_relative 'profile_bio_panel_builder/builder'

# Builds a Bootstrap panel with a profile's biodata/"profile" information.
class ProfileBioPanelBuilder
  include Contracts

  Contract String => Any
  def initialize(user_profile)
    @user_profile = user_profile
    self
  end

  Contract None => String
  def to_html
    reformat Ox.dump(Builder.build_native user_profile)
  end

  private

  Contract String => String
  def reformat(input)
    input.tr("\n", '')
  end

  attr_reader :h, :user_profile
end # class ProfileBioPanelBuilder
