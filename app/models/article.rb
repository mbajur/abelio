class Article < ApplicationRecord
  include Blockable

  has_one :post, as: :postable, dependent: :destroy

  def to_partial_path
    "panel/articles/article"
  end
end
