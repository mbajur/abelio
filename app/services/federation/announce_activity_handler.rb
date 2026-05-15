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
      object_url = object_or_id.is_a?(Hash) ? object_or_id["id"] : object_or_id

      if Federails::Utils::Host.local_url?(object_url)
        resolve_local_post(object_url)
      else
        resolve_remote_post(object_or_id)
      end
    end

    def resolve_local_post(object_url)
      puts "Resolving local post for URL: #{object_url}"

      local_route = Federails::Utils::Host.local_route(object_url)
      puts "Local route resolved: #{local_route.inspect}"

      raise ActiveRecord::RecordNotFound unless local_route&.fetch(:controller, nil) == "federails/server/published" &&
        local_route[:action] == "show" &&
        local_route[:publishable_type] == "posts"

      puts "Try to find post with ID: #{local_route[:id]}"
      Post.find(local_route[:id])
    end

    def resolve_remote_post(object_or_id)
      puts "Resolving remote post for URL: #{object_or_id}"

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
