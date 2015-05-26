
require 'contracts'

require 'timestamp_builder'
require_relative 'index_row_builder/builder'

# Moved from its previous home in a Draper decorator. See Issue #119.
class IndexRowBuilder
  include Contracts

  Contract Fixnum, RespondTo[:name] => IndexRowBuilder
  def initialize(post_count, current_user)
    @current_user = current_user
    @post_count = post_count
    self
  end

  Contract UserInstance => String
  def build(target_user)
    Builder.new(target_user, current_user, post_count) do
      doc << row_for do |row|
        row << target_user_link
        row << post_count_wrapper
        row << timestamp_wrapper
      end
    end.to_html
  end

  private

  attr_reader :current_user, :post_count
end
