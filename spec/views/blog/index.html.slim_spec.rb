
require 'spec_helper'

describe 'blog/index.slim' do
  before :each do
    @blog = BlogData.first
    render
  end

  describe 'has the correct structure, including' do

    before :each do
      @rows = assert_select 'div.row'
    end

    it 'a total of two "row" divs' do
      expect(@rows).to have(2).items
    end

    describe 'a page-header row' do

      it 'as the first row' do
        header_row = assert_select 'div.page-header.row'
        expect(header_row).to have(1).item
        expect(header_row.first).to eq @rows.first
      end

      it 'containing the correct top-level header' do
        assert_select @rows.first, 'h1', text: @blog.title, count: 1
      end

    end # describe 'a page-header row'

    describe 'a second top-level div' do

      before :each do
        @div = assert_select('div')[1]
      end

      it 'with the correct CSS class' do
        expect(@div['class']).to eq 'page-content'
      end

      it 'with one child elements ' do
        expect(@div.children).to have(1).items
      end

      describe 'with a child that is a a row "well" div' do

        before :each do
          @row = assert_select(@div, '> div').first
        end

        it 'with the correct CSS classes' do
          classes = @row['class'].split(' ')
          expect(classes).to include 'row'
          expect(classes).to include 'well'
        end
      end # describe 'with a first child of a row "well" div'
    end # describe 'a second top-level div'

  end # describe 'has the correct structure, including'
end
