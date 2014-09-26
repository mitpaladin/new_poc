
RSpec::Matchers.define :have_same_basic_content_fields_as do |other|

  match do |actual|
    actual.title == other.title &&
        actual.body == other.body &&
        actual.image_url == other.image_url
  end

  description do
    'have the same content fields, including title, body and image URL'
  end

  failure_message do
    'Expected two objects such as an entity and an implementation model to' +
        description
  end
end
