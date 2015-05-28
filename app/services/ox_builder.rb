
require 'contracts'

module Services
  class OxBuilder
    include Contracts

    DOCUMENT_TYPE = Ox::Document
    ELEMENT_TYPE = Ox::Element

    Contract None => OxBuilder
    def initialize
      Ox.default_options = { indent: 0, encoding: 'UTF-8' }
      self
    end

    Contract Proc => ELEMENT_TYPE
    def build(&block)
      instance_eval(&block)
    end

    Contract None => DOCUMENT_TYPE
    def doc
      @doc ||= new_doc
    end

    Contract Any => String
    def dump(what)
      Ox.dump what
    end

    private

    Contract String => ELEMENT_TYPE
    def element(name)
      Ox::Element.new name
    end

    Contract None => DOCUMENT_TYPE
    def new_doc
      Ox::Document.new
    end
  end # class Services::OxBuilder
end
