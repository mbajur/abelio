module Public
  class SiteSerializer < BaseSerializer
    def data
      {
        "name" => resource.name,
        "summary" => resource.summary,
        "avatar" => { "url" => resource.logo_url },
        "federated_url" => resource.federails_actor.federated_url
      }
    end
  end
end
