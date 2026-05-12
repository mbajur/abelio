class Article < ApplicationRecord
  include Blockable
  include Federails::DataEntity

  # @todo moved to initializer, bring it back
  # acts_as_federails_data handles: "Article",
  #                        actor_entity_method: :site

  has_one :post, as: :postable, dependent: :destroy
  has_one :site, through: :post

  def to_partial_path
    "panel/articles/article"
  end
end
