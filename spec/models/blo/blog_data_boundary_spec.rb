
require 'spec_helper'

require 'support/shared_examples/models/blo/blog_data_boundary/a_bdo_attribute'

# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  describe BlogDataBoundary do
    describe 'has accessors for' do

      subject(:blog_data) { BlogDataBoundary.new }

      it_behaves_like 'a BDO attribute', 'string-like', :title, :present?

      it_behaves_like 'a BDO attribute', 'string-like', :subtitle, :present?

      it_behaves_like 'a BDO attribute', 'array-like', :entries, :empty?
    end # describe 'has accessors for'
  end # describe BLO::BlogDataBoundary
end # module BLO
