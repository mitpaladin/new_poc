
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
