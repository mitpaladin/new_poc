
require 'spec_helper'

describe Newpoc::Repository::Base do
  it 'has a version number' do
    expect(Newpoc::Repository::Base::VERSION).to match(/\d+\.\d+\.\d+/)
  end
end
