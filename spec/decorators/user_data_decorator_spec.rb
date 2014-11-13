
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
            expect(content).to eq user.timestamp_for(user.created_at)
          end
        end # describe 'contains a formatted timestamp with'
      end # describe 'the third table-data cell'
    end # context 'without the user being the currently logged-in user'
  end # describe :build_index_row_for
end # describe UserDataDecorator
