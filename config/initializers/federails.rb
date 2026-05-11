Federails.config_from "federails"

# @todo Federails::ServerController parent class should be configurable
Rails.application.config.to_prepare do
  Federails::ServerController.class_eval do
    include Authentication
    allow_unauthenticated_access
  end
end

Rails.application.config.after_initialize do
  # Fediverse::Inbox.register_handler("Create", "*", ActivityPub::ActorActivityHandler, :handle_create_activity)
  # Fediverse::Inbox.register_handler("Update", "*", ActivityPub::ActorActivityHandler, :handle_update_activity)
  Fediverse::Inbox.register_handler("Like", "*", Federation::LikeActivityHandler, :handle_like_activity)
  Fediverse::Inbox.register_handler("Undo", "Like", Federation::UndoLikeActivityHandler, :handle_undo_like_request)
  Fediverse::Inbox.register_handler("Announce", "*", Federation::AnnounceActivityHandler, :handle_announce_activity)
  # Fediverse::Inbox.register_handler("QuoteRequest", "*", ActivityPub::QuoteRequestHandler, :handle_quote_request)
end
