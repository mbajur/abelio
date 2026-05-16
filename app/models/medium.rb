class Medium < ApplicationRecord
  include ActionText::Attachable
  include MediumFileUploader::Attachment(:file)
end
