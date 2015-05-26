
require 'contracts'

# Builds user-index row for a specific user.
class IndexRowBuilder
  class OxBuilder
    include Contracts

    Contract Maybe[Proc] => OxBuilder
    def initialize
      Ox.default_options = { indent: 0, encoding: 'UTF-8' }
      self
    end

    Contract None => String
    def dump
      Ox.dump doc
    end

    private

    Contract String, Maybe[Proc] => Ox::Element
    def element(name)
      Ox::Element.new(name).tap { |ret| yield ret if block_given? }
    end

    Contract String, String => Ox::Element
    def link_to(text, url)
      element('a').tap do |elem|
        elem[:href] = url
        elem << text
      end
    end

    Contract None => Ox::Document
    def doc
      @doc ||= new_doc
    end

    Contract None => Ox::Document
    def new_doc
      Ox::Document.new
    end
  end # class IndexRowBuilder::OxBuilder
end # class IndexRowBuilder
