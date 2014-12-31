
require 'spec_helper'

# Barest-bones specs for structure of MelddRepository Gem.

describe MelddRepository do
  it 'has a VERSION constant that is a semver-compliant string' do
    expect(MelddRepository::VERSION).to be_a String
    expect(MelddRepository::VERSION).to match(/\d+\.\d+\.\d+.*/)
  end
end # describe MelddRepository
