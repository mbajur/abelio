require "rails_helper"

describe Public::Block::ImageSerializer do
  describe "#data" do
    let(:resource) { create(:block_image, :with_file) }

    it "serializes file url and metadata" do
      data = described_class.new(resource).data

      expect(data).to eq({
        "file" => {
          "url" => resource.file_url(host: nil),
          "metadata" => resource.file.metadata
        }
      })
    end
  end
end
