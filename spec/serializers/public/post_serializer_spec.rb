require "rails_helper"

describe Public::PostSerializer do
  describe "#data" do
    let(:post) do
      create(
        :post,
        federated_url: "https://example.com/federation/published/posts/1",
        published_at: Time.zone.parse("2026-05-12 10:00:00 UTC"),
        likes_count: 4,
        announces_count: 2,
        content: "Hello world!"
      )
    end

    it "serializes post" do
      data = described_class.new(post).data

      expect(data).to eq({
        "name" => "Hardcoded name",
        "type" => "article",
        "path" => Rails.application.routes.url_helpers.post_path(post),
        "federated_url" => "https://example.com/federation/published/posts/1",
        "published_at" => Time.zone.parse("2026-05-12 10:00:00 UTC"),
        "likes_count" => 4,
        "boosts_count" => 2,
        "replies_count" => 0,
        "content" => "<div class=\"trix-content\">\n  Hello world!\n</div>\n"
      })
    end
  end
end
