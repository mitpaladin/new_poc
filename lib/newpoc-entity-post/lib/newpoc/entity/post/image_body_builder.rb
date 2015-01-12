
module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      module SupportClasses
        # Build image-post body.
        class ImageBodyBuilder
          # Note that since Markdown has no specific support for the
          # :figure, :img, or :figcaption tags beyond being a superset of
          # HTML (valid HTML in a Markdown document should be processed
          # correctly), we're leaving the `#build` method as is here.
          def build(obj)
            doc = build_document
            # FIXME: Feature envy for `figure`.
            figure = build_figure doc
            figure << build_image(doc, obj.image_url)
            figure << build_figcaption(doc, obj.body)
            figure.to_html
          end

          private

          def body_markup(markup)
            Newpoc::Services::MarkdownHtmlConverter.new.to_html(markup)
            # markup
          end

          def build_document
            Nokogiri::HTML::Document.new
          end

          def build_figcaption(doc, body)
            Nokogiri::XML::Element.new('figcaption', doc).tap do |figcaption|
              figcaption << body_markup(body)
            end
          end

          def build_figure(doc)
            Nokogiri::XML::Element.new 'figure', doc
          end

          def build_image(doc, image_url)
            Nokogiri::XML::Element.new('img', doc).tap do |img|
              img[:src] = image_url
            end
          end
        end # class Newpoc::Entity::Post::SupportClasses::ImageBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
