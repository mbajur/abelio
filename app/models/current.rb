class Current < ActiveSupport::CurrentAttributes
  attribute :session, :site, :site_following_actor_ids

  delegate :user, to: :session, allow_nil: true
end
