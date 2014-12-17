
require 'spec_helper'

# Get the fugly markup/HTML building for fenced code blocks out of the specs.
class FCBData
  def self.expected
    [
      %(<p>Leading content</p>\n),
      %(<pre class="highlight ruby"><code>),
      _expected_func_start,
      _expected_func_end
    ].join
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

  def self._expected_func_end
    [
      %(  <span class="nb">format</span> ),
      %(<span class="s1">'bar = %s, options = %s'</span>),
      %(<span class=\"p\">,</span> <span class=\"n\">bar</span>),
      %(<span class=\"p\">,</span> <span class=\"n\">options</span>),
      %(<span class=\"p\">.</span><span class=\"nf\">inspect</span>\n),
      %(<span class=\"k\">end</span>\n</code></pre>\n)
    ]
  end

  def self._expected_func_start
    [
      %(<span class="c1"># This is a Ruby comment. D'oh!</span>\n),
      %(<span class="k">def</span> <span class="nf">foo</span>),
      %(<span class="p">\(</span><span class="n">bar</span> ),
      %(<span class="o">=</span> <span class="s1">'bar'</span>),
      %(<span class="p">,</span> <span class="n">options</span> ),
      %(<span class="o">=</span> <span class="p">{}\)</span>\n)
    ]
  end
end

# Get the fugly markup/HTML building for table data out of the specs.
class TableData
  def self.expected
    [
      %(<table><thead>\n<tr>\n<th>Tables</th>\n),
      %(<th style="text-align: center">Are</th>\n),
      %(<th style="text-align: right">Cool</th>\n),
      %(</tr>\n</thead><tbody>\n<tr>\n<td>col 3 is</td>\n),
      %(<td style="text-align: center">right-aligned</td>\n),
      %(<td style="text-align: right">$1600</td>\n),
      %(</tr>\n</tbody></table>\n)
    ].join
  end

  def self.markup
    [
      %(| Tables        | Are           | Cool  |\n),
      %(| ------------- |:-------------:| -----:|\n),
      %(| col 3 is      | right-aligned | $1600 |)
    ].join
  end
end

describe MarkdownHtmlConverter do
  it 'can be constructed' do
    expect(MarkdownHtmlConverter.new).to be_a MarkdownHtmlConverter
    # ...and not raise an error, naturally...
  end

  describe 'correctly parses markup including' do

    after :each do
      expect(MarkdownHtmlConverter.new.to_html @markup).to eq @expected
    end

    it 'autolinks' do
      @markup = 'Visit http://www.example.com/ and see for yourself!'
      @expected = '<p>Visit <a href="http://www.example.com/">' \
        'http://www.example.com/</a> and see for yourself!</p>' \
        "\n"
    end

    it 'fenced code blocks' do
      @markup = FCBData.markup
      @expected = FCBData.expected
    end

    it 'highlight' do
      @markup = 'This is ==highlighted== and this is not.'
      @expected = '<p>This is <mark>highlighted</mark> and this is not.</p>' \
          "\n"
    end

    it 'no_intra_emphasis' do
      @markup = 'This has a snake_case_style string in it.'
      @expected = '<p>This has a snake<u>case</u>style string in it.</p>' "\n"
    end

    it 'strikethrough' do
      @markup = 'This is ~~hideous~~excellent'
      @expected = '<p>This is <del>hideous</del>excellent</p>' "\n"
    end

    it 'superscript' do
      @markup = 'At script^super and after'
      @expected = '<p>At script<sup>super</sup> and after</p>' "\n"
    end

    it 'tables' do
      @markup = TableData.markup
      @expected = TableData.expected
    end

    it 'underline' do
      @markup = 'This may be _underlined_ but this is still *emphasised*.'
      @expected = '<p>This may be <u>underlined</u> but this is still ' \
          "<em>emphasised</em>.</p>\n"
    end
  end # describe 'correctly parses markup including'
end # describe MarkdownHtmlConverter
