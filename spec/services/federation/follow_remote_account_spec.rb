require "rails_helper"

describe Federation::FollowRemoteAccount do
  describe "#call" do
    let(:local_actor) { instance_double("Federails::Actor") }
    let(:remote_actor) { instance_double("Federails::Actor") }
    let(:following) { instance_double("Federails::Following") }

    it "creates a following between local and remote actors" do
      service = described_class.new(local_actor: local_actor, remote_actor: remote_actor)

      expect(Federails::Following).to receive(:create_or_find_by!).with(
        actor: local_actor,
        target_actor: remote_actor
      ).and_return(following)

      expect(service.call).to eq(following)
    end
  end
end
