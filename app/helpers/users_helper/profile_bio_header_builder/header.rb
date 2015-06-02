
require 'contracts'

require 'current_user_identity'
require_relative '../../../services/ox_builder'

require_relative 'button'

# Builds a header element. It contains a button if the named user is logged in.
class ProfileBioHeaderBuilder
  class Builder < Services::OxBuilder
    class Header
      include Contracts

      def self.build_native(title_text, button)
        Ox::Element.new('h1').tap do |h1|
          h1[:class] = 'bio'
          h1 << title_text
          h1 << button if button
        end
      end
    end # class ProfileBioHeaderBuilder::Builder::Header
  end # class ProfileBioHeaderBuilder::Builder
end # class ProfileBioHeaderBuilder
