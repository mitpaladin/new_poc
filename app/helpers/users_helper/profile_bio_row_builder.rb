
# Builds a Bootstrap-styled "row" with a panel containing profile/"biodata" text
# for a user.
class ProfileBioRowBuilder
  def initialize(user_name, user_profile, h)
    @user_name, @user_profile, @h = user_name, user_profile, h
  end

  # NOTE: PAY ATTENTION! WTF WORKAROUND IN PROGRESS!
  # This started out as a fairly conventional Rails view-helper method, with the
  # outer block below appearing as:
  #     h.content_tag :div, nil, { class: 'row' }, false do
  #       # innards pretty much as is
  #     end
  # The WTF is that, despite the very explicit `false` parameter to #content_tag
  # (which should disable escaping), the content added by the block WAS escaped
  # (and thus invalid as HTML).
  #
  # Nokogiri, the Swiss Army Nuclear Ginsu Chainsaw, to the rescue!
  def to_html
    outer_div = outer_container do |div|
      div['class'] = 'row'
      div << ProfileBioHeaderBuilder.new(user_name, h).to_html
      div << ProfileBioPanelBuilder.new(user_profile, h).to_html
    end
    reformat_html_output outer_div
  end

  protected

  attr_reader :h, :user_name, :user_profile

  private

  def outer_container
    doc = Nokogiri::HTML::Document.new
    Nokogiri::XML::Element.new('div', doc).tap { |div| yield div }.to_html
  end

  def reformat_html_output(markup)
    markup.lines.each(&:strip!).join
  end
end
