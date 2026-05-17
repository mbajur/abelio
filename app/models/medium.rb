class Medium < ApplicationRecord
  include ActionText::Attachable
  include MediumFileUploader::Attachment(:file)

  belongs_to :site
  belongs_to :entity, polymorphic: true, optional: true

  def representable?
    file.mime_type.start_with?("image/")
  end
end
