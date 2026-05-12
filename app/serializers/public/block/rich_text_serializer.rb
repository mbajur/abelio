module Public
  module Block
    class RichTextSerializer < BaseSerializer
      def data
        {
          "content" => resource.content.to_s
        }
      end
    end
  end
end
