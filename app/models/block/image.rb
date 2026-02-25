class Block::Image < ApplicationRecord
  include Block::Image::FileUploader::Attachment(:file)
end
