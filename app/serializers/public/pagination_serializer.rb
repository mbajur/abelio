module Public
  class PaginationSerializer < BaseSerializer
    def data
      {
        "page" => resource.page,
        "count" => resource.count,
        "page_key" => resource.options[:page_key]
      }
    end
  end
end
