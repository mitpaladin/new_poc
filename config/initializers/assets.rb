# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(
  markdown-toolbar.png
  text_blockquote.png
  text_bold.png
  text_code.png
  text_delimiter.png
  text_empty.png
  text_heading_1.png
  text_heading_2.png
  text_heading_3.png
  text_image.png
  text_italic.png
  text_link.png
  text_list_bullets.png
  text_list_numbers.png
  text_strike.png
  text_underline.png
  )
