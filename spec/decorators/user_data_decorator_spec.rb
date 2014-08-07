
require 'spec_helper'

describe UserDataDecorator do

  let(:user) { UserDataDecorator.new FactoryGirl.attributes_for(:user_datum) }

  describe :build_profile.to_s do

    it 'returns a paragraph wrapping the user profile string' do
      expected = "<p>#{user[:profile]}</p>\n"
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
