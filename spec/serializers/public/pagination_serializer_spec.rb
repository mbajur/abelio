require "rails_helper"

describe Public::PaginationSerializer do
  describe "#data" do
    PaginationResource = Struct.new(:page, :count, :options)
    let(:resource) { PaginationResource.new(3, 25, { page_key: "before" }) }

    it "serializes page metadata" do
      data = described_class.new(resource).data

      expect(data).to eq({
        "page" => 3,
        "count" => 25,
        "page_key" => "before"
      })
    end
  end
end
