class Like < ApplicationRecord
  belongs_to :user
  belongs_to :site
  belongs_to :likeable, polymorphic: true
  belongs_to :federails_activity, class_name: "Federails::Activity"
end
