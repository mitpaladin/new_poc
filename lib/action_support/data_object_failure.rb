
# Various support classes for controller-hosted action classes.
module ActionSupport
  # Raised by Action or support class when data object (entity) is invalid.
  class DataObjectFailure
    def initialize(options)
      @data = build_data_from_options options
    end

    def fail
      Kernel.fail YAML.dump(data)
    end

    private

    attr_reader :data

    def build_data_from_options(options = {})
      messages = options.fetch :messages, []
      attributes = options.fetch :attributes, nil
      data = { messages: messages }
      data[:attributes] = attributes if attributes
      data
    end
  end # class ActionSupport::DataObjectFailure
end # module ActionSupport
