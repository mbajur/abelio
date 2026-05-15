class Announce < ApplicationRecord
  belongs_to :postable, polymorphic: true
  belongs_to :announced_post, class_name: "Post"
end
