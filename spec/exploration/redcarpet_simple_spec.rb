
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
      autolink: true,
      fenced_code_blocks: true,
      tables: true
    }
  end
  let(:renderer) { Redcarpet::Markdown.new(Renderer, renderer_options) }
  let(:base_fragment) do
    "This is a *test*.\n\nAnd another test.\n\nAll _*done*_."
  end
  let(:fragment) { ['<div id="outer">', base_fragment, '</div>'].join }
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

end # describe 'RedCarpet simple exploration, such that'
