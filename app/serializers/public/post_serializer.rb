module Public
  class PostSerializer < BaseSerializer
    def data
      {
        "name" => "Hardcoded name",
        "type" => resource.postable_type.underscore,
        "path" => Rails.application.routes.url_helpers.post_path(resource),
        "federated_url" => resource.federated_url,
        "published_at" => resource.published_at,
        "likes_count" => resource.likes_count,
        "boosts_count" => resource.announces_count,
        "replies_count" => 0,
        "content" => resource.content.to_s
      }
    end
  end
end
