
require 'contracts'

# Builds user-index row for a specific user.
class IndexRowBuilder
  # Temporary class to localise Nokogiri API usage.
  class NokogiriBuilder
    include Contracts

    Contract None => String
    def dump
      doc.to_html
    end

    Contract String, Maybe[Proc] => Nokogiri::XML::Element
    def element(name)
      ret = Nokogiri::XML::Element.new name, doc
      ret.tap { yield ret if block_given? }
    end

    Contract String, String => Nokogiri::XML::Element
    def link_to(text, url)
      element('a').tap do |elem|
        elem[:href] = url
        elem << text
      end
    end

    private

    Contract None => Nokogiri::HTML::Document
    def doc
      @doc ||= new_doc
    end

    Contract None => Nokogiri::HTML::Document
    def new_doc
      Nokogiri::HTML::Document.new
    end
  end # class IndexRowBuilder::NokogiriBuilder
end # class IndexRowBuilder
