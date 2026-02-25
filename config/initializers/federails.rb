Federails.config_from "federails"

# @todo Federails::ServerController parent class should be configurable
Rails.application.config.to_prepare do
  Federails::ServerController.class_eval do
    include Authentication
    allow_unauthenticated_access
  end
end
