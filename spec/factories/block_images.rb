require "base64"
require "tempfile"

FactoryBot.define do
  factory :block_image, class: "Block::Image" do
    trait :with_file do
      after(:build) do |image|
        next if image.file_attacher.attached?

        png_data = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Z0ioAAAAASUVORK5CYII=")
        tempfile = Tempfile.new([ "block-image", ".png" ])

        begin
          tempfile.binmode
          tempfile.write(png_data)
          tempfile.rewind
          image.file = tempfile
        ensure
          tempfile.close!
        end
      end
    end
  end
end
