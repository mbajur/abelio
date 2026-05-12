require "rails_helper"

describe Public::Block::ImageSetSerializer do
  describe "#data" do
    let(:resource) { create(:block_image_set) }
    let(:article) { create(:article) }
    let!(:root) { create(:block, resource: article, blockable: resource) }
    let(:image_one) { create(:block_image, :with_file) }
    let(:image_two) { create(:block_image, :with_file) }
    let!(:image_one_block) { create(:block, resource: root.resource, parent: root, blockable: image_one) }
    let!(:image_two_block) { create(:block, resource: root.resource, parent: root, blockable: image_two) }

    it "serializes all child image blocks" do
      data = described_class.new(resource).data

      expect(data).to eq({
        "images" => [
          Public::Block::ImageSerializer.new(image_one).data,
          Public::Block::ImageSerializer.new(image_two).data
        ]
      })
    end
  end
end
