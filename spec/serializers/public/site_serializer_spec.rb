require "rails_helper"

describe Public::SiteSerializer do
  describe "#data" do
    let(:site) { create(:site, name: "Example", summary: "About example") }

    it "serializes public site fields" do
      data = described_class.new(site).data

      expect(data).to eq({
        "name" => "Example",
        "summary" => "About example",
        "avatar" => { "url" => site.logo_url(host: nil) },
        "federated_url" => site.federails_actor.federated_url
      })
    end
  end
end
