module Sketchable
  extend ActiveSupport::Concern

  included do
    belongs_to :sketch_of, class_name: "Post", optional: true
    has_many :sketches, class_name: "Post", foreign_key: :sketch_of_id, dependent: :nullify

    scope :sketches, -> { where.not(sketch_of_id: nil) }
    scope :non_sketches, -> { where(sketch_of_id: nil) }

    def sketch?
      sketch_of_id.present?
    end
  end
end
