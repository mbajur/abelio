require "rails_helper"

describe Public::BlockSerializer do
  describe "#data" do
    let(:rich_text_blockable) { create(:block_rich_text, content: "<p>Hello world</p>") }
    let(:resource) { create(:block, blockable: rich_text_blockable) }
    let(:unknown_article) { create(:article) }

    it "serializes type and merges blockable serializer data" do
      data = described_class.new(resource).data

      expect(data).to eq({
        "type" => "rich_text",
        "content" => resource.blockable.content.to_s
      })
    end

    it "returns only type when specific serializer does not exist" do
      unknown_resource = Block.new(blockable_type: "Block::Unknown", blockable_id: 1, resource: unknown_article)

      data = described_class.new(unknown_resource).data

      expect(data).to eq({ "type" => "unknown" })
    end
  end
end
