class Federails::LikeActivityHandler
  def self.handle_like_activity(activity_hash_or_id)
    activity = Fediverse::Request.dereference(activity_hash_or_id)
    actor = Federails::Actor.find_or_create_by_object activity["actor"]
    object = Fediverse::Request.dereference(activity["object"])

    entity = begin
      Federails::Actor.find_by_federation_url(object["id"])&.entity
    rescue ActiveRecord::RecordNotFound
      Federails::Utils::Object.find_or_create!(object)
    end
    raise ActiveRecord::RecordNotFound unless entity

    Federails::Activity.create! actor: actor, action: "Like", entity: entity

    entity.update_likes_count!
  end
end
