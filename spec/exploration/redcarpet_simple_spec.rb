
require 'spec_helper'

require 'rouge/plugins/redcarpet'

def enclose_markup(markup)
  ['<div id="outer">', markup, '</div>'].join
end

describe 'RedCarpet simple exploration, such that' do
  # Renderer to which we add Rouge/Pygments syntax highlighting for code blocks.
  class Renderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  let(:renderer_options) do
    {
      # autolink: true,
      # fenced_code_blocks: true,
      # tables: true
    }
  end
  let(:renderer) { Redcarpet::Markdown.new(Renderer, renderer_options) }
  let(:base_fragment) do
    "This is a *test*.\n\nAnd another test.\n\nAll _*done*_."
  end
  let(:fragment) { enclose_markup base_fragment }
  let(:base_markup) { renderer.render base_fragment }
  let(:markup) do
    enclose_markup renderer.render(base_fragment)
  end

  it 'parsing an uncontained sequence of elements yields only the first' do
    parsed = Nokogiri.parse base_markup
    expect(parsed.name).to eq 'document'
    expect(parsed.children.length).to eq 1
    expect(parsed.children.first.name).to eq 'p'
    full_para = '<p>This is a <em>test</em>.</p>'
    para_text = 'This is a test.'
    expect(parsed.children.first.to_html).to eq full_para
    expect(parsed.children.first.content).to eq para_text
  end

  it 'parsing a block element containing children yields entire content' do
    parsed = Nokogiri.parse markup
    expect(parsed.name).to eq 'document'
    expect(parsed.children.length).to eq 1
    expect(parsed.children.first.name).to eq 'div'
    div = parsed.children.first
    # Remove text nodes -- embedded newlines separating top-level elements.
    kids = div.children.reject { |k| k.name == 'text' }
    expect(kids.length).to eq 3
  end

  describe 'we can poke at options, such as' do

    describe ':no_intra_emphasis' do
      let(:fragment) { 'This has a snake_case_style string in it.' }
      let(:renderer) { Redcarpet::Markdown.new Renderer, options }
      let(:markup) { renderer.render fragment }
      let(:true_regex) { /.+?snake_case_style.+/ }
      let(:false_regex) { Regexp.new('.+?snake<em>case</em>style.+') }

      describe 'when set to' do

        context 'true' do
          let(:options) { { no_intra_emphasis: true } }

          it 'does not emphasise snake_case_style strings' do
            expect(markup).to match true_regex
          end
        end # context 'true'

        context 'false' do
          let(:options) { { no_intra_emphasis: false } }

          it 'replaces snake_case_style strings with emphasised words' do
            expect(markup).to match false_regex
          end
        end # context 'false'
      end # describe 'when set to'

      describe 'defaults to' do
        let(:options) { {} }

        it 'false' do
          expect(markup).to match false_regex
        end
      end # describe 'defaults to'
    end # describe ':no_intra_emphasis'

    describe ':tables' do
      let(:renderer) { Redcarpet::Markdown.new Renderer, options }
      let(:bad_markup) { renderer.render bad_fragment }

      describe 'must have' do

        describe 'headings' do
          let(:bad_fragment) { '| col 3 is      | right-aligned | $1600 |' }
          let(:fragment) do
            "| Tables        | Are           | Cool  |\n" \
            "| ------------- |:-------------:| -----:|\n" \
            '| col 3 is      | right-aligned | $1600 |'
          end
          let(:markup) { renderer.render fragment }
          let(:options) { { tables: true } }

          it 'to generate the correct markup' do
            matcher_str = '\<table\>\<thead\>.+\<\/thead\>' \
              '\<tbody\>.+\<\/tbody\>\<\/table\>'
            matcher = Regexp.new matcher_str
            # Squish replaces multiple whitespace (including newlines) with a
            # single space.
            expect(markup.squish).to match matcher
          end

          it 'otherwise table markup is not generated' do
            expect(bad_markup).to eq ['<p>', bad_fragment, "</p>\n"].join
          end
        end # describe 'headings'
      end # describe 'must have'

      describe 'must NOT have' do

        describe 'footers' do
          let(:bad_fragment) do
            "| Tables        | Are           | Cool  |\n" \
            "| ------------- |:-------------:| -----:|\n" \
            "| col 3 is      | right-aligned | $1600 |\n" \
            "| ------------- |:-------------:| -----:|\n" \
            '| Tables        | Are           | Cool  |'
          end
          let(:options) { { tables: true } }

          it 'or else garbage markup is generated in place of `tfoot`' do
            expect(bad_markup.squish).not_to match(/.+?tfoot.+?/)
          end
        end # describe 'footers'
      end # describe 'must NOT have'

      describe 'always include' do
        let(:fragment) do
          "| Tables        | Are           | Cool  |\n" \
          "| ------------- |:-------------:| -----:|\n" \
          '| col 3 is      | right-aligned | $1600 |'
        end
        let(:markup) { renderer.render fragment }
        let(:options) { { tables: true } }

        it 'a final newline' do
          expect(markup).to match(/<table>.+?<\/table>\n/m)
        end
      end

      context 'basic demo' do
        let(:fragment) do
          "| Tables        | Are           | Cool  |\n" \
          "| ------------- |:-------------:| -----:|\n" \
          "| col 3 is      | right-aligned | $1600 |\n" \
          "| col 2 is      | centered      |   $12 |\n" \
          '| zebra stripes | are neat      |    $1 |'
        end
        let(:renderer) { Redcarpet::Markdown.new Renderer, options }
        let(:markup) { renderer.render fragment }
        let(:false_markup) { ['<p>', fragment, "</p>\n"].join }

        describe 'when set to' do

          context 'true' do
            let(:options) { { tables: true } }

            it 'creates an HTML table from the markup' do
              expect(markup).to match(/<table>.+?<\/table>\n/m)
            end
          end # context 'true'

          context 'false' do
            let(:options) { { tables: false } }

            it 'creates no HTML table but returns original markup in a `p`' do
              expect(markup).to eq false_markup
            end
          end
        end # describe 'when set to'

        describe 'defaults to' do
          let(:options) { {} }

          it 'false' do
            expect(markup).to eq false_markup
          end
        end # describe 'defaults to'
      end # context 'basic demo'
    end # describe ':tables'

    describe ':fenced_code_blocks' do
      let(:fragment) do
        "Leading content\n\n" \
        "```ruby\n" \
        "# This is a Ruby comment. D'oh!\n" \
        "def foo(bar = 'bar', options = {})\n" \
        "  format 'bar = %s, options = %s', bar, options.inspect\n" \
        "end\n" \
        "```\n\n" \
        'Trailing content'
      end
      let(:renderer) { Redcarpet::Markdown.new Renderer, options }
      let(:markup) { renderer.render fragment }
      let(:false_matcher) do
        match_str = '<p>Leading content</p>\s+?' \
            '<p>```.+?```</p>\s+?<p>Trailing content</p>'
        Regexp.new match_str, Regexp::MULTILINE
      end

      describe 'when set to' do

        context 'true' do
          let(:options) { { fenced_code_blocks: true } }

          it 'formats the code block embedded in the markup' do
            match_str = '<p>Leading content</p>\s+?' \
              '<pre><code class="highlight ruby">.+?' \
              '</code></pre>\s+?<p>Trailing content</p>'
            matcher = Regexp.new match_str, Regexp::MULTILINE
            expect(markup).to match matcher
          end
        end # context 'true'

        context 'false' do
          let(:options) { { fenced_code_blocks: false } }

          it 'creates no pre-formatted code block in the markup' do
            expect(markup).to match false_matcher
          end
        end # context 'false'
      end # describe 'when set to'

      describe 'defaults to' do
        let(:options) { {} }

        it 'false' do
          expect(markup).to match false_matcher
        end
      end # describe 'defaults to'
    end # describe ':fenced_code_blocks'
  end # describe "we can poke at options, such as"

end # describe 'RedCarpet simple exploration, such that'
