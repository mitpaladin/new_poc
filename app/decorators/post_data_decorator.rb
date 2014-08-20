
require 'draper'

require_relative './post_data_decorator/image_body_builder'
require_relative './post_data_decorator/text_body_builder'

# PostDataDecorator: Draper Decorator, aka ViewModel, for the PostData model.
class PostDataDecorator < Draper::Decorator
  decorates_finders
  delegate_all

  # After Avdi's #render_body; his "exhibits" are much more closely associated
  # with views than Draper's decorators are. While that's a perfectly valid
  # choice, especially the way he abstracts it, I've chosen differently. Since
  # the question "is this an image post or a text post" is answered purely by
  # consulting the contents of the *model*, it seems to me entirely natural to
  # add the outcome of that question to something closely associated with, but
  # not strictly part of, the model. Doing so obviates the entire question of
  # view partial templates, replacing them with "pure Ruby" code.
  def build_body
    fragment = body_builder_class.new(helpers).build self
    convert_body fragment
  end

  def build_byline
    BylineBuilder.new(self).to_html
  end

  def published?
    pubdate.present?
  end

  private

  def body_builder_class
    if image_url.present?
      SupportClasses::ImageBodyBuilder
    else
      SupportClasses::TextBodyBuilder
    end
  end

  def convert_body(fragment)
    MarkdownHtmlConverter.new.to_html(fragment)
  end
end # class PostDataDecorator
