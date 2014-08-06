
require 'draper'

require_relative './post_data_decorator/image_body_builder'
require_relative './post_data_decorator/text_body_builder'

require 'rouge/plugins/redcarpet'

# PostDataDecorator: Draper Decorator, aka ViewModel, for the PostData model.
class PostDataDecorator < Draper::Decorator
  delegate_all

  # Redcarpet Markdown output renderer. Uses Rouge for syntax highlighting.
  class Renderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

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
    # `fragment` is Markdown, HTML or some combination thereof; run it through
    # RedCarpet's Markdown parser to yield HTML to return to caller.
    renderer = Redcarpet::Markdown.new Renderer, conversion_options
    renderer.render fragment
  end

  def conversion_options
    {
      autolink:                     true,
      fenced_code_blocks:           true,
      highlight:                    true,
      no_intra_emphasis:            false,
      strikethrough:                true,
      superscript:                  true,
      tables:                       true,
      underline:                    true
    }
  end
end # class PostDataDecorator
