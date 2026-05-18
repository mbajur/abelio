class Announce < ApplicationRecord
  has_one :post, as: :postable, dependent: :destroy
  has_one :site, through: :post

  def to_partial_path
    "panel/announces/announce"
  end
end
