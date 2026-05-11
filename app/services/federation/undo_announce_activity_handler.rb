class Federation::UndoAnnounceActivityHandler
  def self.handle_undo_announce_request(activity)
    original_activity = activity["object"]
    actor = Federails::Actor.find_or_create_by_object(original_activity["actor"] || activity["actor"])

    object_id = original_activity["object"]
    raise "Not a local ID" unless Federails::Utils::Host.local_url?(object_id)

    local_route = Federails::Utils::Host.local_route(object_id)
    raise ActiveRecord::RecordNotFound unless local_route[:controller] == "federails/server/published" && local_route[:action] == "show" && local_route[:publishable_type] == "posts"

    entity = Post.find(local_route[:id])
    announce = Federails::Activity.find_by actor: actor, entity: entity, action: "Announce"
    announce&.destroy

    entity.update_announces_count!
  end
end
