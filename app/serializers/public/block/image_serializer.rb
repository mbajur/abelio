module Public
  module Block
    class ImageSerializer < BaseSerializer
      def data
        {
          "file" => {
            "url" => resource.file_url(host: nil),
            "metadata" => resource.file.metadata
          }
        }
      end
    end
  end
end
