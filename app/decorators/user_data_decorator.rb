
require 'draper'

# UserDataDecorator: Draper Decorator, aka ViewModel, for the UserData model.
class UserDataDecorator < Draper::Decorator
  decorates_finders
  delegate_all

  def build_profile
    MarkdownHtmlConverter.new.to_html @object[:profile]
  end

  def self.policy_class
    UserDataPolicy
  end
end # class UserDataDecorator
