require "rails_helper"

describe Public::PostSerializer do
  describe "#data" do
    let(:post) do
      create(
        :post,
        federated_url: "https://example.com/federation/published/posts/1",
        published_at: Time.zone.parse("2026-05-12 10:00:00 UTC"),
        likes_count: 4,
        announces_count: 2
      )
    end
    let(:root_blockable) { create(:block_rich_text, content: "<p>Hello</p>") }
    let!(:root_block) { create(:block, resource: post.postable, blockable: root_blockable) }
    let!(:child_block) do
      create(:block, resource: post.postable, parent: root_block, blockable: create(:block_rich_text, content: "<p>Child</p>"))
    end

    it "serializes post fields and top-level content blocks" do
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
        "content_blocks" => [
          Public::BlockSerializer.new(root_block).data
        ]
      })
    end
  end
end
