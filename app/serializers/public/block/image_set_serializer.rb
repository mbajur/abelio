module Public
  module Block
    class ImageSetSerializer < BaseSerializer
      def data
        {
          "images" => resource.block.children.order(:lft).map { |block| Public::Block::ImageSerializer.new(block.blockable).data }
        }
      end
    end
  end
end
