
require 'draper'

# UserDataDecorator: Draper Decorator, aka ViewModel, for the UserData model.
class UserDataDecorator < Draper::Decorator
  delegate_all

  def build_profile
    MarkdownHtmlConverter.new.to_html @object[:profile]
  end
end # class UserDataDecorator
