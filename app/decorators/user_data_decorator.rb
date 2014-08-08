
require 'draper'

require_relative './post_data_decorator/content_converter'

# UserDataDecorator: Draper Decorator, aka ViewModel, for the UserData model.
class UserDataDecorator < Draper::Decorator
  include PostDataDecorator::SupportClasses # FIXME: Smell much?
  delegate_all

  def build_profile
    ContentConverter.new.to_html @object[:profile]
  end
end # class UserDataDecorator
