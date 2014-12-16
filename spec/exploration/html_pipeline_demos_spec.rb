
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
  let(:pipeline) { HTML::Pipeline.new filters, context }

  describe 'a single MarkdownFilter pipeline' do
    let(:filters) { [HTML::Pipeline::MarkdownFilter] }

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

  describe 'a PlainTextInputFilter-plus-SanitizationFilter pipeline' do
    let(:filters) do
      [HTML::Pipeline::SanitizationFilter, HTML::Pipeline::PlainTextInputFilter]
    end

    # This is because a PlainTextFilter "html escape text and wrap the result"
    # *in a div*. Oopsie.
    it 'rejects Markdown content, complaining that it is HTML' do
      expect { pipeline.call gruber_content_markdown }
        .to raise_error TypeError, 'text cannot be HTML'
    end
  end # describe 'a PlainTextInputFilter-plus-SanitizationFilter pipeline'

  describe 'a single SanitizationFilter pipeline' do
    let(:filters) do
      [HTML::Pipeline::SanitizationFilter]
    end

    after :each do
      result = pipeline.call @input
      expect(result.keys).to eq [:output]
      output = result[:output]
      expect(output).to be_a Nokogiri::HTML::DocumentFragment
      expect(output.to_html).to eq @expected
    end

    it 'ignores Markdown' do
      @input = gruber_content_markdown
      @expected = gruber_content_markdown
    end

    it 'strips non-whitelisted HTML tags' do
      @input = '<form><textarea name="foo"></textarea></form>'
      @expected = ''
    end
  end # describe 'a single SanitizationFilter pipeline'

  describe 'an HttpsFilter pipeline' do
    let(:filters) do
      [HTML::Pipeline::MarkdownFilter, HTML::Pipeline::HttpsFilter]
    end

    after :each do
      result = pipeline.call @input
      expect(result[:output]).to be_a Nokogiri::HTML::DocumentFragment
      expect(result[:output].to_html).to eq @expected
    end

    it 'changes an http to https URL for an image (for proxying)' do
      http_url = 'http://example.com'
      secure_url = 'https://example.com'
      context[:http_url] = http_url
      @input = "[image 1](#{http_url}/images/foo.png)"
      @expected = "<p><a href=\"#{secure_url}/images/foo.png\">image 1</a></p>"
    end

    it 'does not modify URLs for subdomains' do
      context[:http_url] = 'http://example.com/'
      @input = '[image 1](http://images.example.com/foo.png)'
      link = '<a href="http://images.example.com/foo.png">image 1</a>'
      @expected = ['<p>', '</p>'].join link
    end
  end

  describe "all filters we're likely to use in a pipeline" do
    let(:context) do
      {
        asset_root: 'https://images.example.com/',
        gfm: true
      }
    end
    let(:filters) do
      [
        HTML::Pipeline::MarkdownFilter,
        HTML::Pipeline::SanitizationFilter,
        # HTML::Pipeline::CamoFilter,
        HTML::Pipeline::ImageMaxWidthFilter,
        HTML::Pipeline::HttpsFilter,
        HTML::Pipeline::MentionFilter,
        HTML::Pipeline::EmojiFilter,
        HTML::Pipeline::SyntaxHighlightFilter
      ]
    end

  end # describe "all filters we're likely to use in a pipeline"
end # describe 'HTML::Pipeline simple exploration, demoing'
