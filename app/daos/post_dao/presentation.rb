
require 'posts/html_body_builder'
require 'posts/byline_builder'

# Data-access bag-of-fields object for posts.
class PostDao < ActiveRecord::Base
  # Presentation extension module for PostDao.
  # This is a direct analogue to a Rails helper module; one difference is that
  # it's used to extend a PostDao instance explicitly, rather than trying to
  # figure out why a non-generated `PostDaoHelper` module doesn't get auto-
  # loaded by Rails.
  #
  # Bear in mind that the module here is used to extend a PostDao, so that a
  # view template can call what look like methods on the DAO instance it's been
  # handed without having to worry about where that stuff comes from. This is
  # also a direct analogue to something like a Draper decorator, without
  # bringing in a new Gem dependency to add to the floating crapshoot that is
  # `Gemfile.lock`.
  module Presentation
    include TimestampBuilder

    def build_body
      Decorations::Posts::HtmlBodyBuilder.new.build self
    end

    def build_byline
      Decorations::Posts::BylineBuilder.build self
    end

    def draft?
      pubdate.nil?
    end

    def post_status
      pubdate ? 'public' : 'draft'
    end

    def post_status=(new_status)
      return unless new_status
      self.pubdate = pubdate_for_status(new_status)
    end

    def pubdate_str
      return 'DRAFT' if draft?
      timestamp_for pubdate
    end

    def published?
      !draft?
    end

    private

    def pubdate_for_status(new_status)
      case new_status
      when 'public'
        Time.zone.now
      when 'draft'
        nil
      else
        pubdate
      end
    end
  end
end # class PostDao
