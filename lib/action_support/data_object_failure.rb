
require 'contracts'

# Supporting code used by and for controller-namespaced Action classes.
module ActionSupport
  # Build and raise a RuntimeError with YAML-encoded data as message.
  class DataObjectFailure
    include Contracts

    Contract RespondTo[:to_hash] => DataObjectFailure
    def initialize(options)
      @data = build_data_from_options options
      self
    end

    Contract None => AlwaysRaises
    def fail
      Kernel.fail YAML.dump(data)
    end

    private

    attr_reader :data

    Contract RespondTo[:to_hash] => HashOf[Symbol, Any]
    def build_data_from_options(options = {})
      messages = options.fetch :messages, []
      attributes = options.fetch :attributes, nil
      data = { messages: messages }
      data[:attributes] = attributes if attributes
      data
    end
  end # class ActionSupport::DataObjectFailure
end # module ActionSupport
