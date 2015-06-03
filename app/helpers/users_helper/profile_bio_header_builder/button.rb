
require 'contracts'

require 'current_user_identity'
require_relative '../../../services/ox_builder'

# Builds a header element. It contains a button if the named user is logged in.
class ProfileBioHeaderBuilder
  class Builder < Services::OxBuilder
    class Button
      include Contracts

      Contract String => Builder::ELEMENT_TYPE
      def self.build_native(current_user_edit_path)
        Builder::ELEMENT_TYPE.new(:a).tap do |a|
          a[:class] = 'btn btn-xs pull-right'
          a[:href] = current_user_edit_path
          a << 'Edit Your Profile'
        end
      end
    end # class ProfileBioHeaderBuilder::Builder::Button
  end # class ProfileBioHeaderBuilder::Builder
end # class ProfileBioHeaderBuilder
