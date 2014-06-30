
require 'spec_helper'

require 'cco/blog_cco2'

# Second-generation CCO for Blogs. Does not (presently) subclass Base.
module CCO
  describe BlogCCO2 do
    let(:from) { BlogCCO2.public_method :from_entity }
    let(:to) { BlogCCO2.public_method :to_entity }

    describe 'has a .from_entity method that' do

      it 'is a class method' do
        expect(from.receiver).to be BlogCCO2
      end

      it 'takes two parameters' do
        expect(from.arity.abs).to eq 2
      end

      describe 'takes two parameters, where' do
        it 'the first parameter is required' do
          param = from.parameters.first
          expect(param[0]).to be :req
        end

        it 'the second parameter is optional' do
          param = from.parameters.second
          expect(param[0]).to be :opt
        end
      end # describe 'takes two parameters, where'
    end # describe 'has a .from_entity method that'

    describe 'has a .to_entity method that' do
      let(:impl) { BlogData.first }

      it 'is a class method' do
        expect(to.receiver).to be BlogCCO2
      end

      it 'takes one required parameter' do
        expect(to.arity).to be 1
        expect(to.parameters.first[0]).to be :req
      end

      it 'returns a Blog instance when called with a BlogData parameter' do
        expect(BlogCCO2.to_entity impl).to be_a Blog
      end
    end # describe 'has a .to_entity method that'
  end # describe CCO::BlogCCO2
end # module CCO
