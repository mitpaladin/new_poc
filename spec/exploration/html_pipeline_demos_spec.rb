
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

def gfm_highlighted_fenced_code_block_html
  '<div class="highlight highlight-ruby">' \
  '<pre><span class="k">def</span> <span class="nf">foo</span>' \
  '<span class="p">(</span><span class="n">bar</span>' \
  '<span class="p">)</span>' "\n" \
  '  <span class="n">quux</span> <span class="o">&lt;&lt;</span>' \
  ' <span class="n">bar</span>' "\n" \
  '<span class="k">end</span>' "\n" \
  '</pre></div>'
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
  end # describe 'an HttpsFilter pipeline'

  describe 'a MentionFilter pipeline' do
    let(:filters) { [HTML::Pipeline::MentionFilter] }

    after :each do
      result = pipeline.call @input
      expect(result[:mentioned_usernames]).to eq @mentions
      expect(result[:output]).to be_a Nokogiri::HTML::DocumentFragment
      expect(result[:output].to_html).to eq @expected
    end

    it 'uses a base_url of "/" if none is specified' do
      @input = 'Mentioning @jch.'
      @expected = 'Mentioning <a href="/jch" class="user-mention">@jch</a>.'
      @mentions = ['jch']
    end

    it 'uses a specified base_url to build @mention URLs' do
      context[:base_url] = 'http://example.com/'
      @input = 'Mentioning @jch.'
      @mentions = ['jch']
      @expected = 'Mentioning <a href="http://example.com/jch"' \
        ' class="user-mention">@jch</a>.'
    end
  end # describe 'a MentionFilter pipeline'

  describe 'an EmojiFilter pipeline' do
    let(:asset_root) { 'http://example.com/' }
    let(:filters) { [HTML::Pipeline::EmojiFilter] }

    it 'raises an ArgumentError if no :asset_root is specified' do
      @input = 'All done? :shipit:'
      message = 'Missing context keys for HTML::Pipeline::EmojiFilter:' \
        ' :asset_root'
      expect { pipeline.call @input }.to raise_error ArgumentError, message
    end

    it 'generates the expected markup for a valid emoji' do
      @input = 'All done? :shipit:'
      result = pipeline.call @input, asset_root: asset_root
      expect(result.keys).to eq [:output]
      expect(result[:output]).to have(2).children
      img = result[:output].children.last
      expect(img.name).to eq 'img'
      expect(img['class']).to eq 'emoji'
      expect(img['title']).to eq ':shipit:'
      expect(img['alt']).to eq ':shipit:'
      expect(img['src']).to eq 'http://example.com/emoji/shipit.png'
    end

    describe 'does not generate markup when the emoji is inside' do
      after :each do
        result = pipeline.call @input, asset_root: asset_root
        expect(result.keys).to eq [:output]
        expect(result[:output]).to be_a Nokogiri::HTML::DocumentFragment
        expect(result[:output].to_html).to eq @input
      end

      it 'a :code tag' do
        @input = '<code>:shipit:</code>'
      end

      it 'a :pre tag' do
        @input = '<pre>:shipit:</pre>'
      end

      it 'a :tt tag' do
        @input = '<tt>:shipit:</tt>'
      end
    end # describe 'does not generate markup when the emoji is inside'
  end # describe 'an EmojiFilter pipeline'

  describe 'a SyntaxHighlightFilter (with Markdown for convenience) pipeline' do
    let(:filters) do
      [HTML::Pipeline::MarkdownFilter, HTML::Pipeline::SyntaxHighlightFilter]
    end

    after :each do
      result = pipeline.call @input, gfm: true
      expect(result[:output].to_html).to eq @expected
    end

    it 'generates the correct highlighting markup for recognised code' do
      @input = gfm_plain_fenced_code_block_markdown
      @expected = gfm_highlighted_fenced_code_block_html
    end

    it 'does not highlight unrecognised code' do
      @input = "```foobb\nanything goes here\n```\n\n"
      @expected = %(<pre lang=\"foobb"><code>anything goes here\n</code></pre>)
    end
  end # describe 'a SyntaxHighlightFilter (with Markdown...) pipeline'

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
        # HTML::Pipeline::HttpsFilter,
        HTML::Pipeline::MentionFilter,
        HTML::Pipeline::EmojiFilter,
        HTML::Pipeline::SyntaxHighlightFilter
      ]
    end

  end # describe "all filters we're likely to use in a pipeline"
end # describe 'HTML::Pipeline simple exploration, demoing'
