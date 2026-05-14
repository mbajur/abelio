require "rails_helper"

describe Federation::UnfollowRemoteAccount do
  describe "#call" do
    let(:local_actor) { instance_double("Federails::Actor") }
    let(:remote_actor) { instance_double("Federails::Actor") }
    let(:service) { described_class.new(local_actor: local_actor, remote_actor: remote_actor) }

    it "destroys following and returns true when relationship exists" do
      following = instance_double("Federails::Following")

      expect(Federails::Following).to receive(:find_by).with(
        actor: local_actor,
        target_actor: remote_actor
      ).and_return(following)
      expect(following).to receive(:destroy!).and_return(true)

      expect(service.call).to eq(true)
    end

    it "returns false when following does not exist" do
      expect(Federails::Following).to receive(:find_by).with(
        actor: local_actor,
        target_actor: remote_actor
      ).and_return(nil)

      expect(service.call).to eq(false)
    end

    it "raises when local_actor is missing" do
      missing_local_actor = described_class.new(local_actor: nil, remote_actor: remote_actor)

      expect { missing_local_actor.call }.to raise_error(ArgumentError, "local_actor is required")
    end

    it "raises when remote_actor is missing" do
      missing_remote_actor = described_class.new(local_actor: local_actor, remote_actor: nil)

      expect { missing_remote_actor.call }.to raise_error(ArgumentError, "remote_actor is required")
    end
  end
end
