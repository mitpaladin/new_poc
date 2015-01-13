
# Get the fugly markup/HTML building for fenced code blocks out of the specs.
class FCBData
  # Markup that varies between HTML::Pipeline and, e.g., RedCarpet.
  module HtmlPipeline
    def self.preamble
      "<p>Leading content</p>\n\n"
    end

    def self.code_block_start
      '<div class="highlight highlight-ruby"><pre>'
    end

    def self.code_block_end
      '</pre></div>'
    end
  end # module FCBData::HtmlPipeline
  private_constant :HtmlPipeline

  def self.expected
    mod = HtmlPipeline
    str = [
      mod.preamble,
      mod.code_block_start,
      '.*',
      mod.code_block_end
    ].join
    Regexp.new str, Regexp::MULTILINE
  end

  def self.markup
    [
      %(Leading content\n\n```ruby\n),
      %(# This is a Ruby comment. D'oh!\n),
      %(def foo(bar = 'bar', options = {})\n),
      %(  format 'bar = %s, options = %s', bar, options.inspect\n),
      %(end\n```\n\n)
    ].join
  end
end # class FCBData
