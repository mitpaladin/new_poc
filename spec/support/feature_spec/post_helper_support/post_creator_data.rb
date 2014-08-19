
require_relative '../../sequencer'

module PostHelperSupport
  # Encapsulates/sequences data suitable for post generation.
  class PostCreatorData
    def initialize(params = {})
      title_format = params.fetch :post_title, 'Post Title %d'
      post_start = params.fetch :post_start, 0
      @post_title = Sequencer.new title_format, post_start
      format_str = 'This is *another* post body. (Number %d in a series.)'
      body_format = params.fetch :post_body, format_str
      @post_body = Sequencer.new body_format, post_start
    end

    def post_body
      @post_body.to_s
    end

    def post_title
      @post_title.to_s
    end
  end # class PostHelperSupport::PostCreatorData
end # module PostHelperSupport
