
require 'contracts'

require 'current_user_identity'
require_relative '../../../services/ox_builder'

require_relative 'header'

# Builds a header element. It contains a button if the named user is logged in.
class ProfileBioHeaderBuilder
  class Builder < Services::OxBuilder
    include Contracts

    def self.build_native(user_name, current_user, h)
      title_text = "Profile Page for #{user_name}"
      edit_path = h.edit_user_path(current_user.slug)
      button = Button.build_native(edit_path) if current_user.name == user_name
      Builder.new.build do
        element('h1').tap do |h1|
          h1[:class] = 'bio'
          h1 << title_text
          h1 << button if button
        end
      end
    end
  end # class ProfileBioHeaderBuilder::Builder
end # class ProfileBioHeaderBuilder
