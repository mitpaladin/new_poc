
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can publish an article and' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    FeatureSpecNewPostHelper.new(self).create_image_post
    # should be back on landing page now
  end

  # NOTE: DANGER! HARD-CODED VALUE SUBJECT TO CHANGE (coming from factory)!
  it 'view it on the landing page' do
    figcaption = page.find('figcaption').native.to_html
    expected = '<figcaption>' \
        "<p>This is a Body with <em>Emphasised</em> Content!</p>\n" \
        '</figcaption>'
    expect(figcaption).to eq expected
  end
end # describe 'Member can publish articles and'
