
require 'spec_helper'

require 'chronic'
require 'fancy-open-struct'
require 'pry'

require 'newpoc/entity/post/byline_builder'

module Newpoc
  module Entity
    class Post
      # *Private* support classes used by Post entity class.
      module SupportClasses
        describe BylineBuilder do
          let(:author) { 'The Author' }
          let(:builder) { described_class.new params }
          let(:params) do
            FancyOpenStruct.new author_name: author,
                                :draft? =>  false,
                                updated_at: updated_at,
                                pubdate_str: pubdate_str
          end
          let(:pubdate_str) { 'PUBDATE_STR HERE' }
          let(:time_format) { '%a %b %e %Y at %R %Z (%z)' }
          let(:updated_at) { Chronic.parse '2 January 2015 at 1:23:45 AM' }
          let(:updated_str) { updated_at.localtime.strftime time_format }

          describe 'initialisation' do
            let(:draft) { false }

            it 'raises no errors' do
              expect { builder }.not_to raise_error
            end
          end # describe 'initialisation'

          describe '#to_html produces the expected HTML for a' do
            let(:expected_format) do
              '<p><time pubdate="pubdate">%s %s by %s</time></p>'
            end

            after :each do
              expect(builder.to_html).to eq @expected
            end

            it 'draft post' do
              params[:draft?] = true
              @expected = format expected_format, 'Drafted', updated_str, author
            end

            it 'public post' do
              params[:draft?] = false
              @expected = format expected_format, 'Posted', pubdate_str, author
            end
          end # describe '#to_html produces the expected HTML for a'
        end # class Newpoc::Entity::Post::SupportClasses::BylineBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
