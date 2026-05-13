class ActorPresenter < BasePresenter
  def avatar_url
    local? ? record.entity.logo_url(host: nil) : record.extensions.dig("icon", "url")
  end
end
