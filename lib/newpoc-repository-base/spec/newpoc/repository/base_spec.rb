require 'spec_helper'

describe Newpoc::Repository::Base do
  it 'has a version number' do
    expect(Newpoc::Repository::Base::VERSION).not_to be nil
  end
end
