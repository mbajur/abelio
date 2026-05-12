module Public
  class BlockSerializer < BaseSerializer
    def data
      {
        "type" => resource.blockable_type.demodulize.underscore
      }.merge(blockable_data)
    end

    private

    def blockable_data
      serializer_class = "Public::Block::#{resource.blockable_type.demodulize}Serializer".safe_constantize
      return {} unless serializer_class

      serializer_class.new(resource.blockable).data
    end
  end
end
