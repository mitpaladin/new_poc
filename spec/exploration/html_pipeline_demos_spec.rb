
require 'spec_helper'

require 'pygments'
require 'html/pipeline'

def gfm_at_mention_markdown
  'This mentions @jch in the markup'
end

def gfm_emoji_markdown
  'This does nothing special. :expressionless:'
end

def gfm_plain_fenced_code_block_markdown
  "```ruby\n\ndef foo(bar)\n  quux << bar\nend\n\n```\n\n"
end

def gfm_plain_fenced_code_block_html
  %(<pre lang="ruby"><code>\n) \
  "def foo(bar)\n  quux &lt;&lt; bar\nend\n\n" \
  '</code></pre>'
end

def gruber_content_markdown
  "This is *emphasised* and this is **bold**.\n\n" \
  "    This is indented sufficiently to be treated as code.\n" \
  "* This\n* *is*\n* a\* list.\n"
end

def gruber_content_html
  "<p>This is <em>emphasised</em> and this is <strong>bold</strong>.</p>\n\n" \
  "<pre><code>This is indented sufficiently to be treated as code.\n" \
  "</code></pre>\n\n" \
  "<ul>\n<li>This</li>\n<li><em>is</em></li>\n<li>a* list.</li>\n</ul>"
end

### ######################################################################## ###
### ######################################################################## ###
### ######################################################################## ###

describe 'HTML::Pipeline simple exploration, demoing' do
  let(:context) do
    {
      asset_root: 'https://images.example.com/',
      gfm: false
    }
  end

  describe 'a single MarkdownFilter pipeline' do
    let(:pipeline) do
      HTML::Pipeline.new [HTML::Pipeline::MarkdownFilter], context
    end

    after :each do
      result = pipeline.call @input
      expect(result.keys).to eq [:output]
      expect(result[:output]).to eq @expected
    end

    it 'parses canonical Gruber Markdown' do
      @input = gruber_content_markdown
      @expected = gruber_content_html
    end

    it 'parses non-Gruber GFM fenced code blocks without syntax highlighting' do
      @input = gfm_plain_fenced_code_block_markdown
      @expected = gfm_plain_fenced_code_block_html
    end

    it 'does not parse GFM @mentions' do
      @input = gfm_at_mention_markdown
      @expected = ['<p>', '</p>'].join @input
    end

    it 'does not parse GFM emoji' do
      @input = gfm_emoji_markdown
      @expected = ['<p>', '</p>'].join @input
    end
  end # describe 'a single MarkdownFilter pipeline'
end # describe 'HTML::Pipeline simple exploration, demoing'
