
require 'spec_helper'

describe Newpoc::Dao::Post::AR do
  it 'has a version number' do
    expect(Newpoc::Dao::Post::AR::VERSION).not_to be nil
  end

  describe 'supports initialisation' do
    describe 'succeeding' do
      it 'with no parameters' do
        expect { described_class.new }.not_to raise_error
      end
    end # describe 'succeeding'
  end # describe 'supports initialisation'
end
