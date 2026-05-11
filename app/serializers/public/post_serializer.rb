module Public
  class PostSerializer < BaseSerializer
    def data
      {
        "name" => "Hardcoded name",
        "path" => Rails.application.routes.url_helpers.post_path(resource),
        "federated_url" => resource.federated_url,
        "published_at" => resource.published_at,
        "likes_count" => resource.likes_count,
        "boosts_count" => 0,
        "replies_count" => 0
      }
    end
  end
end
