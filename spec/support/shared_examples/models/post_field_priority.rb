
shared_examples 'Post field priority' do |params|
  higher_string = 'string2'
  lower_string = 'string1'

  # Unpack parameters
  params ||= {}
  higher = params.fetch :higher, higher_string
  lower = params.fetch :lower, lower_string
  others = params[:others]
  priority = "#{params[:priority]}=".to_sym

  # Write nice description
  others_str = others.each(&:to_s)
               .join(', ')
               .sub(/, (\S+)$/, ' or \1')
               .sub(/image_url/, 'image URL')
  description = "#{params[:priority]} has higher priority than " + others_str
  description.sub(/, (^[,]+)$/, ' and \1')

  it description do
    post = Post.new FactoryGirl.attributes_for(:post_datum)
    post2 = post.clone

    post.send priority, lower
    post2.send priority, higher
    others.each do |other|
      other = "#{other}=".to_sym
      post.send other, higher_string
      post2.send other, lower_string
      expect(post2 > post).to be true
    end
  end
end # shared_examples
