
require 'spec_helper'

require 'support/shared_examples/blog_helper/a_call_to_entries_for'

describe BlogHelper do
  describe '#entries_for' do

    it_behaves_like 'a call to #entries_for with no parameters'

    it_behaves_like 'a call to #entries_for with a blog parameter'

  end # describe '#entries_for'
end
