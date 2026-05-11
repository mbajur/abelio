class Federation::UndoLikeActivityHandler
  def self.handle_undo_like_request(activity)
    original_activity = Request.dereference(activity["object"])
    actor  = Federails::Actor.find_or_create_by_object original_activity["actor"]

    object_id = original_activity["object"]
    raise "Not a local ID" unless Federails::Utils::Host.local_url?(object_id)

    local_route = Federails::Utils::Host.local_route(object_id)
    Rails.logger.info local_route
    raise ActiveRecord::RecordNotFound unless local_route[:controller] == "federails/server/published" && local_route[:action] == "show" && local_route[:publishable_type] == "posts"

    entity = Post.find(local_route[:id])
    Rails.logger.info entity.as_json
    like = Federails::Activity.find_by actor: actor, entity: entity, action: "Like"
    Rails.logger.info like.as_json
    like&.destroy!

    entity.update_likes_count!
  end
end
