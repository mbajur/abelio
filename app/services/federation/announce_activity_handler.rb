class Federation::AnnounceActivityHandler
  def self.handle_announce_activity(activity_hash_or_id)
    activity = Fediverse::Request.dereference(activity_hash_or_id)
    actor = Federails::Actor.find_or_create_by_object activity["actor"]
    object = Fediverse::Request.dereference(activity["object"])

    object_id = object["id"]
    raise "Not a local ID" unless Federails::Utils::Host.local_url?(object_id)

    local_route = Federails::Utils::Host.local_route(object_id)
    raise ActiveRecord::RecordNotFound unless local_route[:controller] == "federails/server/published" && local_route[:action] == "show" && local_route[:publishable_type] == "posts"

    entity = Post.find(local_route[:id])
    Federails::Activity.find_or_create_by! actor: actor, action: "Announce", entity: entity

    entity.update_announces_count!
  end
end
