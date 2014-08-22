
require 'spec_helper'

describe UserDataDecorator do

  # Have to actually create a record; we're dealing with Rails timestamps.
  let(:user) { UserDataDecorator.new FactoryGirl.create(:user_datum) }

  describe :build_index_row_for.to_s do
    let(:post_count) { 5 }

    context 'without the user being the currently logged-in user' do
      let(:markup) { user.build_index_row_for post_count }
      let(:top_node) { Nokogiri.parse(markup).children.first }

      describe 'the outermost tag' do
        it 'is a "tr" tag' do
          expect(top_node.name).to eq 'tr'
        end

        it 'has no CSS classes' do
          expect(top_node['class']).to be nil
        end

        it 'contains three children' do
          expect(top_node).to have(3).children
        end
      end # describe 'the outermost tag'

      describe 'the first table-data cell' do
        let(:cell) { top_node.children.first }

        it 'is a "td" tag' do
          expect(cell.name).to eq 'td'
        end

        it 'has no CSS classes' do
          expect(cell['class']).to be nil
        end

        it 'contains a single child node' do
          expect(cell).to have(1).child
        end

        describe 'has a child element that' do
          let(:child) { cell.children.first }

          it 'is an "a" tag' do
            expect(child.name).to eq 'a'
          end

          it 'links to the user_path' do
            expect(child['href']).to eq h.user_path(user)
          end

          it 'has the user name as content' do
            expect(child.content).to eq user.name
          end
        end # describe 'has a child element that'
      end # describe 'the first table-data cell'

      describe 'the second table-data cell' do
        let(:cell) { top_node.children[1] }

        it 'is a "td" tag' do
          expect(cell.name).to eq 'td'
        end

        it 'has no CSS classes' do
          expect(cell['class']).to be nil
        end

        it 'has a single child node' do
          expect(cell).to have(1).children
        end

        it 'has content of the number of posts' do
          expect(cell.children.first.content).to eq post_count.to_s
        end
      end # describe 'the second table-data cell'

      describe 'the third table-data cell' do
        let(:cell) { top_node.children[2] }

        it 'is a "td" tag' do
          expect(cell.name).to eq 'td'
        end

        it 'has no CSS classes' do
          expect(cell['class']).to be nil
        end

        it 'has a single child node' do
          expect(cell).to have(1).children
        end

        describe 'contains a formatted timestamp with' do
          let(:content) { cell.content }

          it 'the correct local-time format' do
            format = '%a %b %e %Y at %R %Z (%z)'
            expected = user.created_at.localtime.strftime format
            expect(content).to eq expected
          end
        end # describe 'contains a formatted timestamp with'
      end # describe 'the third table-data cell'
    end # context 'without the user being the currently logged-in user'
  end # describe :build_index_row_for

  describe :build_profile.to_s do

    # NOTE: Another bit that's dependent on factory data. Any better ideas?
    it 'returns a paragraph wrapping the user profile string' do
      # @user_bio currently has one italicised content fragment in ordinary text
      parts = user[:profile]
          .match(/(.+?)\s+?\*(.+?)\*\s+?(.+)/)
          .to_a
          .slice(1..3)
      expected = format "<p>%s <em>%s</em> %s</p>\n", *parts
      expect(user.build_profile).to eq expected
    end

    it 'returns an empty string given a blank or empty string' do
      user[:profile] = ''
      expect(user.build_profile).to eq ''
      user[:profile] = ' '
      expect(user.build_profile).to eq ''
      user[:profile] = " \n \t"
      expect(user.build_profile).to eq ''
      user[:profile] = nil
      expect(user.build_profile).to eq ''
    end

    describe 'returns correct HTML given valid Markdown for' do
      it 'simple inline elements' do
        user[:profile] = 'This *is* a _test_ of the system^(2).'
        expected = '<p>This <em>is</em> a <u>test</u> of the system' \
            "<sup>2</sup>.</p>\n"
        expect(user.build_profile).to eq expected
      end

      it 'multiple paragraphs' do
        # Note that *two* newlines are needed at the end of a paragraph. The
        # Markdown spec says that paragraphs are separated by blank lines, NOT
        # simply by newline characters. This doesn't always consciously register
        # the first *n* times you're writing it.
        user[:profile] = %(This is a test.\n\nThis is only a test.\n\nAll done!)
        expected = "<p>This is a test.</p>\n\n<p>This is only a test.</p>\n\n" \
            "<p>All done!</p>\n"
        expect(user.build_profile).to eq expected
      end

      describe 'lists that are' do

        it 'ordered' do
          user[:profile] = "\nContent\n\n1. One\n1. Two\n1. Three\n\n" \
              "More content!\n"
          expected = "<p>Content</p>\n\n<ol>\n<li>One</li>\n<li>Two</li>\n" \
              "<li>Three</li>\n</ol>\n\n<p>More content!</p>\n"
          expect(user.build_profile).to eq expected
        end

        it 'unordered' do
          user[:profile] = "\nContent\n\n* One\n* Two\n* Three\n\n" \
              "More content!\n"
          expected = "<p>Content</p>\n\n<ul>\n<li>One</li>\n<li>Two</li>\n" \
              "<li>Three</li>\n</ul>\n\n<p>More content!</p>\n"
          expect(user.build_profile).to eq expected
        end
      end # describe 'lists that are'

      describe 'links that are' do

        # NOTE: Footnotes are NOT presently enabled. See
        #       https://github.com/jdickey/new_poc/pull/73#issuecomment-51308335
        #       for details on why.
        it 'autolinks' do
          user[:profile] = 'Visit http://www.example.com for details.'
          expected = '<p>Visit <a href="http://www.example.com">' \
              "http://www.example.com</a> for details.</p>\n"
          expect(user.build_profile).to eq expected
        end

        it '"normal" links' do
          user[:profile] = 'Visit [here](http://www.example.com) today!'
          expected = '<p>Visit <a href="http://www.example.com">here</a> ' \
              "today!</p>\n"
          expect(user.build_profile).to eq expected
        end
      end # describe 'links that are'

      it 'blockquotes' do
        user[:profile] = "> This is the first level\n>\n" \
            "> > This is the second level\n>\n" \
            '> This is the first level again.'
        expected = "<blockquote>\n" \
            "<p>This is the first level</p>\n\n" \
            "<blockquote>\n<p>This is the second level</p>\n</blockquote>\n\n" \
            "<p>This is the first level again.</p>\n</blockquote>\n"
        expect(user.build_profile).to eq expected
      end
    end # describe 'returns correct HTML given valid Markdown for'
  end # describe :build_profile
end # describe UserDataDecorator
