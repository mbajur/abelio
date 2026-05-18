require "rails_helper"

xdescribe Federation::AnnounceActivityHandler do
  describe ".handle_announce_activity" do
    let(:site) { create(:site) }
    let(:post) { create(:post, site: site) }

    let(:local_url) { "https://aptest4.mbajur.com/federation/published/posts/#{post.id}" }
    let(:remote_actor_url) { "https://remote.example.com/users/alice" }

    let(:activity_hash) do
      {
        "@context" => [ "https://www.w3.org/ns/activitystreams", "https://w3id.org/security/v1" ],
        "id" => "https://remote.example.com/users/alice/statuses/116556938996951374/activity",
        "type" => "Announce",
        "actor" => remote_actor_url,
        "published" => "2026-05-11T16:42:25Z",
        "to" => [ "https://www.w3.org/ns/activitystreams#Public" ],
        "cc" => [
          "https://aptest4.mbajur.com/federation/actors/77e203a6-5c42-4009-a238-cc2d075d2038",
          "https://remote.example.com/users/alice/followers"
        ],
        "object" => local_url
      }
    end

    let(:remote_actor_hash) do
      {
        id: remote_actor_url,
        type: "Person",
        name: "Alice",
        preferred_username: "alice",
        inbox: "https://remote.example.com/users/alice/inbox",
        outbox: "https://remote.example.com/users/alice/outbox",
        followers: "https://remote.example.com/users/alice/followers",
        following: "https://remote.example.com/users/alice/following",
        url: "https://remote.example.com/users/alice"
      }.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
    end

    let(:post_ap_hash) do
      { "id" => local_url, "type" => "Note" }
    end

    before do
      allow(Federails::Utils::Host).to receive(:local_url?).and_return(true)
      allow(Federails::Utils::Host).to receive(:local_route).and_return({
        controller: "federails/server/published",
        action: "show",
        publishable_type: "posts",
        id: post.id
      })

      stub_request(:get, remote_actor_url)
        .to_return(status: 200, body: remote_actor_hash.to_json, headers: { "Content-Type" => "application/activity+json" })
      stub_request(:get, local_url)
        .to_return(status: 200, body: post_ap_hash.to_json, headers: { "Content-Type" => "application/activity+json" })
    end

    context "when activity and actor are successfully dereferenced" do
      it "creates a remote Federails::Actor if it doesn't exist" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to change { Federails::Actor.where(federated_url: remote_actor_url).count }.from(0).to(1)
      end

      it "reuses an existing Federails::Actor" do
        create(:distant_actor, federated_url: remote_actor_url)

        expect {
          described_class.handle_announce_activity(activity_hash)
        }.not_to change { Federails::Actor.count }
      end

      it "creates a Federails::Activity record with action 'Announce'" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to change { Federails::Activity.count }.by(1)

        expect(Federails::Activity.last.action).to eq("Announce")
      end

      it "associates the activity with the correct post" do
        described_class.handle_announce_activity(activity_hash)
        expect(Federails::Activity.last.entity).to eq(post)
      end

      it "updates the post announces count" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to change { post.reload.announces_count }.from(0).to(1)
      end

      it "does not create a duplicate Announce activity for the same actor and post" do
        expect {
          2.times { described_class.handle_announce_activity(activity_hash) }
        }.to change { Federails::Activity.count }.by(1)
      end

      it "handles an Announce activity passed as an ID string" do
        allow(Fediverse::Request).to receive(:dereference).and_call_original
        allow(Fediverse::Request).to receive(:dereference).with("activity-id-789").and_return(activity_hash)

        expect {
          described_class.handle_announce_activity("activity-id-789")
        }.to change { Federails::Activity.count }.by(1)
      end
    end

    context "when the object URL is not a local URL" do
      before { allow(Federails::Utils::Host).to receive(:local_url?).and_return(false) }

      it "raises 'Not a local ID' error" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to raise_error("Not a local ID")
      end
    end

    context "when the local URL does not resolve to a post" do
      before do
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "show",
          publishable_type: "articles",
          id: 123
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the controller is not correct" do
      before do
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "posts",
          action: "show",
          publishable_type: "posts",
          id: post.id
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the action is not show" do
      before do
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "index",
          publishable_type: "posts",
          id: post.id
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the post does not exist" do
      before do
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "show",
          publishable_type: "posts",
          id: 99999
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
