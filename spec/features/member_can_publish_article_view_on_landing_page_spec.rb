
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can publish articles and' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    helper = FeatureSpecNewPostHelper.new(self)
    helper.create_image_post
    helper.step
    helper.create_image_post
    # should be back on landing page now
  end

  # NOTE: DANGER! HARD-CODED VALUE SUBJECT TO CHANGE (coming from data class)!
  it 'view it on the landing page' do
    caption_str = '<figcaption><p>This is <em>another</em> post body.' \
      ' (Number %d in a series.)</p></figcaption>'
    captions = page.all('figcaption')
    expect(captions).to have(2).entries
    # Remember that the items are in "reverse chronological" order!
    captions.to_a.reverse.each_with_index do |caption, index|
      expect(caption.native.to_html).to eq format(caption_str, index + 1)
    end
  end
end # describe 'Member can publish articles and'
