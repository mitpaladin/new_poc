
require 'spec_helper'

require 'cco/post_cco2'

require_relative 'post_shared_examples/post_shared_examples'

# Cross-layer conversion objects (CCOs).
module CCO
  describe PostCCO2 do
    let(:author) { FactoryGirl.build :user_datum }
    let(:ctime) { DateTime.now.to_time }
    let(:klass) { PostCCO2 }

    describe :to_entity.to_s do
      context 'specifying only the implementation object' do

        [:new_post, :saved_post].each do |persist|
          [:draft_post, :public_post].each do |visible|
            [:valid, :invalid].each do |valid|
              it_behaves_like 'a converted entity', persist, visible, valid
            end # valid
          end # visibile
        end # persist
      end # context 'specifying only the implementation object'

      context 'specifying both the implementation and parameter objects' do

        context 'specifying a Blog instance' do
          let(:blog) { Blog.new }
          let(:impl) { FactoryGirl.build :post_datum, :saved_post, :draft_post }
          let(:entity) { CCO::PostCCO2.to_entity impl, converter_params }

          context 'only' do
            let(:converter_params) { { blog: blog } }

            it 'sets the "blog" instance variable on the entity' do
              expect(entity.blog).to be blog
            end

            it "adds the entity to the Blog's list of entries" do
              expect(blog.entry? entity).to be true
            end
          end # context 'only'

          context 'and an add_to_blog value of false' do
            let(:converter_params) { { blog: blog, add_to_blog: false } }

            it 'sets the "blog" instance variable on the entity' do
              expect(entity.blog).to be blog
            end

            it "does NOT add the entity to the Blog's list of entries" do
              expect(blog.entry? entity).to be false
            end
          end # context 'and an add_to_blog value of false' do
        end # context 'specifying a Blog instance'
      end # context 'specifying both the implementation and parameter objects'
    end # describe :to_entity

    describe :from_entity.to_s do
      let(:author_impl) { FactoryGirl.create :user_datum }
      let(:blog) { Blog.new }
      let(:post) { blog.new_post entity_attribs }
      let(:impl) { klass.from_entity post }

      [:new_post, :saved_post].each do |persist|
        [:draft_post, :public_post].each do |visible|
          it_behaves_like 'a converted implementation object', persist, visible
        end
      end
    end # describe :from_entity
  end # describe CCO::PostCCO2
end # module CCO
