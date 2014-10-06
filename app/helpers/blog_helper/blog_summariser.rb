
# Old-style junk drawer of view-helper functions, etc.
module BlogHelper
  # Support class for #summarise_blog method; builds list of Posts.
  class BlogSummariser
    attr_writer :count

    def initialize(&block)
      @count = 10
      @aggregator = -> { PostData.all }
      @selector = -> (data) { data }
      @sorter = -> (data) { data.sort_by(&:pubdate) }
      @orderer = -> (data) { data.reverse }
      @chunker = -> (data) { data.take count }
      instance_eval(&block) if block
    end

    def method_missing(name, *args, &block)
      return super unless dsl_name? name
      instance_variable_set "@#{name}".to_sym, block
    end

    def respond_to?(method, include_private = false)
      super || dsl_name?(method)
    end

    def summarise
      data = PostDataDecorator.decorate_collection @aggregator.call
      summary_steps.each do |op|
        step = ('@' + op.to_s).to_sym
        data = instance_variable_get(step).call data
      end
      data
    end

    private

    attr_reader :count

    def dsl_name?(name)
      dsl_methods.include? name
    end

    def dsl_methods
      [:aggregator, :selector, :sorter, :orderer, :chunker]
    end

    def summary_steps
      dsl_methods.drop(1)
    end
  end # class BlogHelper::BlogSummariser
end # module BlogHelper
