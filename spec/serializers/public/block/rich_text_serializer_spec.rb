require "rails_helper"

describe Public::Block::RichTextSerializer do
  describe "#data" do
    let(:resource) { create(:block_rich_text, content: "<p>Hello</p>") }

    it "serializes rich text content as string" do
      data = described_class.new(resource).data

      expect(data).to eq({ "content" => resource.content.to_s })
    end
  end
end
