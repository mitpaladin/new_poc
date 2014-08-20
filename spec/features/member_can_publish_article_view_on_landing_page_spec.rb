
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
    # NOTE: Regexes Are *Useful* *Evil*, Demonstration #81,271,496.
    #       It took longer to debug the regex than to write the code segment
    #       this spec exercises.
    expected = Regexp.new '\<figcaption\>' \
        '\<p\>This is \<em\>another\</em\> post body\. \(Number (\d+?) in a ' \
        'series\.\)\<\/p\>\s+?\</figcaption\>'
    captions = page.all('figcaption')
    indexes = []
    captions.each do |caption|
      expect(caption.native.to_html).to match expected
      indexes << expected.match(caption.native.to_html)[1].to_i
    end
    # Posts on page are in reverse chrono order, ergo indexes reversed also...
    indexes
        .reverse
        .each_with_index { |value, index| expect(value - 1).to eq index }
  end
end # describe 'Member can publish articles and'
