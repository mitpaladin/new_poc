
description = 'a valid menu for either a Guest or Registered User'
shared_examples description do |current_user, menu_sym|
  user_type = user_type_name_for current_user

  context "when called passing in :#{menu_sym} for a #{user_type}" do
    let(:built_menu) { build_menu_for menu_sym, current_user }
    let(:container) do
      Ox.default_options = { encoding: 'UTF-8' }
      Ox.parse built_menu
    end
    nav_style = if menu_sym == :navbar
                  'navbar-nav'
                elsif menu_sym == :sidebar
                  'nav-sidebar'
                end

    it 'returns a top-level `ul` element' do
      expect(container.value).to eq 'ul'
    end

    describe 'contains a top-level `ul` element that' do
      it "has the 'nav' and '#{nav_style}' CSS classes" do
        classes = container['class'].split
        expect(classes).to include 'nav'
        expect(classes).to include nav_style
      end
    end # describe 'contains a top-level `ul` element that'
  end # context "when called passing in :#{menu_sym} for a #{user_type}"
end # shared_examples 'a valid menu for either a Guest or Registered User'
