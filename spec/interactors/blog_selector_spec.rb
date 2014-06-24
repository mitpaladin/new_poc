
require 'spec_helper'

require 'blog_selector'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe BlogSelector do

    let(:klass) { BlogSelector }
    let(:expected_blog) do
      title = 'Watching Paint Dry'
      subtitle = 'The trusted source for drying paint news and opinion'
      FancyOpenStruct.new title: title, subtitle: subtitle, entries: []
    end

    it 'returns a blog-like object when called with valid parameters' do
      obj = klass.run! params: { blog_params: { id: 1 } }
      expect(obj).to have_same_blog_content_as(expected_blog)
    end

    it 'Does The Right Thing when called without parameters' do
      obj = klass.run!
      expect(obj).to have_same_blog_content_as(expected_blog)
    end

    # all failure specs presently disabled; hardcoding for the moment :P
    # describe 'fails when' do
    #   let(:err_class) { ActiveInteraction::InvalidInteractionError }
    #   let(:error_tail) do
    #     'Params params[:blog_params][:id] must presently be hard-coded as 1'
    #   end
    #
    #   after :each do
    #     message = [@detail, error_tail].join
    #     run_params = {}
    #     run_params = { params: @params } if @params
    #     expect { klass.run! run_params }.to raise_error err_class, message
    #   end
    #
    #   it 'no parameters are passed' do
    #     @params = nil
    #     @detail = 'Params is required, '
    #   end
    #
    #   it 'a :params hash with no :blog_params hash is passed' do
    #     @params = { foo: 'bar' }
    #     @detail = \
    #         'Params has an invalid nested value ("blog_params" => nil), '
    #   end
    #
    #   it 'a :params[:blog_params] hash with no :id value' do
    #     @params = { blog_params: { foo: 'bar' }}
    #     @detail = 'Params has an invalid nested value ("id" => nil), '
    #   end
    #
    #   it 'a :params[:blog_params] hash with a non-numeric :id value' do
    #     @params = { blog_params: { id: 'bar' }}
    #     @detail = 'Params has an invalid nested value ("id" => "bar"), '
    #   end
    #
    #   description = 'a :params[:blog_params] hash with a numeric but' \
    #       ' invalid :id value'
    #   it description do
    #     @params = { blog_params: { id: 2 }}
    #     @detail = ''
    #   end
    # end # describe 'fails when'
  end # describe BlogSelector
end # module DSO
