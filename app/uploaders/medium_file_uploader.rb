class MediumFileUploader < Shrine
  plugin :determine_mime_type
  plugin :validation_helpers

  ALLOWED_MIME_TYPES = %w[
     image/jpeg
     image/png
     image/gif
   ].freeze

   Attacher.validate do
     validate_mime_type_inclusion ALLOWED_MIME_TYPES
   end
end
