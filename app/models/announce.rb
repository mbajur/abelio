class Announce < ApplicationRecord
  has_one :post, as: :postable, dependent: :destroy
  has_one :site, through: :post
end
