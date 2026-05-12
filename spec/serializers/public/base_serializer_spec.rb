require "rails_helper"

describe Public::BaseSerializer do
  describe "#to_liquid" do
    let(:resource) { create(:article) }

    it "returns data as JSON-compatible hash" do
      serializer_class = Class.new(described_class) do
        def data
          { status: :ok, count: 2 }
        end
      end

      serializer = serializer_class.new(resource)

      expect(serializer.to_liquid).to eq({ "status" => "ok", "count" => 2 })
    end
  end
end
