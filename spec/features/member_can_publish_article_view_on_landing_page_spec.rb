
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can publish an article and' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    FeatureSpecNewPostHelper.new(self).create_image_post
    # should be back on landing page now
  end

  # NOTE: DANGER! HARD-CODED VALUE SUBJECT TO CHANGE (coming from data class)!
  it 'view it on the landing page' do
    figcaption = page.find('figcaption').native.to_html
    # NOTE: Regexes Are *Useful* *Evil*, Demonstration #81,271,496.
    #       It took longer to debug the regex than to write the code segment
    #       this spec exercises.
    expected = '\<figcaption\>' \
        '\<p\>This is \<em\>another\</em\> post body\. \(Number (\d+?) in a ' \
        'series\.\)\<\/p\>\s+?\</figcaption\>'
    expect(figcaption).to match expected
  end
end # describe 'Member can publish articles and'
