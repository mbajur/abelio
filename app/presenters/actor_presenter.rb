class ActorPresenter < BasePresenter
  def name_or_username
    record.name.presence || record.username
  end

  def username_with_server
    local? ? record.username : "@#{record.username}@#{record.server}"
  end

  def avatar_url
    local? ? record.entity.logo_url(host: nil) : record.extensions.dig("icon", "url")
  end

  def panel_profile_path
    id = "@#{record.username}@#{record.server}"
    Rails.application.routes.url_helpers.panel_actor_path(id)
  end

  def summary
    local? ? record.entity.summary : record.extensions["summary"]
  end
end
