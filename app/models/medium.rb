class Medium < ApplicationRecord
  include ActionText::Attachable
  include MediumFileUploader::Attachment(:file)

  def representable?
    file.mime_type.start_with?("image/")
  end
end
