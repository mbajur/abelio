class Note < ApplicationRecord
  has_one :post, as: :postable, dependent: :destroy
  has_one :site, through: :post

  def to_partial_path
    "panel/notes/note"
  end
end
