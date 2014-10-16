
require 'support/feature_spec/user_helper_support/user_creator_data.rb'

# Internal support-code module for FeatureSpecLoginHelper class.
module UserHelperSupport
  # Specs for class that encapsulates/sequences data for user generation.
  describe UserCreatorData, support: true do
    describe 'has a method returning a String or equivalent for' do
      let(:obj) { UserCreatorData.new }

      attrib_methods = [
        :user_name,
        :user_email,
        :user_profile,
        :user_password
      ]
      attrib_methods.each do |method_sym|
        it "##{method_sym}" do
          expect(obj).to respond_to method_sym
          method_ret = obj.send method_sym
          expect(method_ret).to respond_to :to_str
          expect(method_ret).to respond_to :<=>
        end
      end
    end # describe 'has a method returning a String or equivalent for'

    describe 'has a #step method that updates' do
      let(:obj) { UserCreatorData.new }
      let(:patterns) do
        {
          user_name:  Regexp.new(/J Random User (\d+?)/),
          user_email: Regexp.new(/jruser(\d+?)\@example\.com/)
        }
      end

      [:user_name, :user_email].each do |method_sym|
        it "the internal field so that ##{method_sym} returns the next value" do
          v1 = obj.send method_sym
          index1 = Integer(patterns[method_sym].match(v1)[1])
          expect(index1).to eq 1
          obj.step
          v2 = obj.send method_sym
          index2 = Integer(patterns[method_sym].match(v2)[1])
          expect(index2).to eq 2
        end
      end
    end # describe 'has a #step method that updates'
  end # describe UserHelperSupport::UserCreatorData
end # module UserHelperSupport
