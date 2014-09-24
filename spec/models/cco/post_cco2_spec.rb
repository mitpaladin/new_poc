
require 'spec_helper'

require 'cco/post_cco2'

# Cross-layer conversion objects (CCOs).
module CCO
  describe PostCCO2 do
    let(:ctime) { Time.now }
    let(:klass) { PostCCO2 }
    let(:new_draft_impl) do
      FactoryGirl.build :post_datum, :new_post, :draft_post, created_at: ctime
    end

    it 'has a .from_entity class method' do
      p = klass.public_method :from_entity
      expect(p.receiver).to be klass
    end

    it 'has a .to_entity class method' do
      p = klass.public_method :to_entity
      expect(p.receiver).to be klass
    end

    describe :to_entity.to_s do
      context 'speciying only the implementation object' do
        let(:entity) { klass.to_entity impl }
        context 'for a new draft post' do
          let(:impl) { new_draft_impl }
          describe 'produces a Post' do
            describe 'with the correct attribute values for' do
              [:author_name,
               :body,
               :image_url,
               :title
              ].each do |method_sym|
                it method_sym do
                  expect(entity.send method_sym).to eq impl.send(method_sym)
                end
              end

              [:blog, :pubdate, :slug].each do |method_sym|
                it method_sym do
                  expect(entity.send method_sym).to be nil
                end
              end

              it :created_at do
                expected = impl.created_at
                expect(entity.created_at).to be_within(0.1.second).of expected
              end
            end # describe 'with the correct attribute values for'

            describe 'with correct values returned from instance methods' do
              it :error_messages do
                expect(entity).to have(0).error_messages
              end

              it :published? do
                expect(entity).not_to be_published
              end

              it :valid? do
                expect(entity).to be_valid
              end
            end # describe 'with correct values returned from instance methods'
          end # describe 'produces a Post'
        end # context 'for a new draft post'

        context 'for a saved draft post' do
        end # context 'for a saved draft post'

        context 'for a new public post' do
        end # context 'for a new draft post'

        context 'for a saved public post' do
        end # context 'for a saved draft post'
      end # context 'speciying only the implementation object'
    end # describe :from_entity
  end # describe CCO::PostCCO2
end # module CCO
