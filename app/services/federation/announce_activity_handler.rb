class Federation::AnnounceActivityHandler
  def self.handle_announce_activity(activity_hash_or_id)
    activity = Fediverse::Request.dereference(activity_hash_or_id)
    actor = Federails::Actor.find_or_create_by_object activity["actor"]
    announced_post = resolve_announced_post(activity["object"])

    Federails::Activity.find_or_create_by! actor: actor, action: "Announce", entity: announced_post
    find_or_create_announce_post!(activity: activity, actor: actor, announced_post: announced_post)

    announced_post.update_announces_count!
  end

  class << self
    private

    def resolve_announced_post(object_or_id)
      post = Federails::Utils::Object.find_or_initialize!(object_or_id)
      raise ActiveRecord::RecordNotFound unless post.is_a?(Post)

      post.save! if post.new_record?
      post
    end

    def find_or_create_announce_post!(activity:, actor:, announced_post:)
      announce_post = Post.find_or_initialize_by(federated_url: activity["id"])
      return announce_post unless announce_post.new_record?

      announce_post.site = Current.site || announced_post.site
      announce_post.federails_actor = actor
      announce_post.state = :distant
      announce_post.published_at = published_at_for(activity)
      announce_post.postable = Announce.new(
        announced_post: announced_post,
        postable: announced_post.postable
      )

      announce_post.save!
      announce_post
    end

    def published_at_for(activity)
      published_at = begin
        Time.zone.parse(activity["published"]) if activity["published"].present?
      rescue ArgumentError, TypeError
        nil
      end

      [ Time.current, published_at ].compact.min
    end
  end
end
