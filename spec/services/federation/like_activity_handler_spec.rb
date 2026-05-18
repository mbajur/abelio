require "rails_helper"

xdescribe Federation::LikeActivityHandler do
  describe ".handle_like_activity" do
    let(:site) { create(:site) }
    let(:post) { create(:post, site: site) }
    let(:remote_actor) { create(:distant_actor) }

    let(:local_url) { "https://aptest4.mbajur.com/federation/published/posts/#{post.id}" }
    let(:remote_actor_url) { "https://mastodon.social/users/mbajur" }

    let(:activity_hash) do
      {
        "@context" => "https://www.w3.org/ns/activitystreams",
        "id" => "https://mastodon.social/users/mbajur#likes/292607539",
        "type" => "Like",
        "actor" => remote_actor_url,
        "object" => local_url,
        "actor_id" => "77e203a6-5c42-4009-a238-cc2d075d2038"
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

    let(:remote_post_hash) do
      {}
    end

    before do
      # Mock the local host resolution
      allow(Federails::Utils::Host).to receive(:local_url?).and_return(true)
      allow(Federails::Utils::Host).to receive(:local_route).and_return({
        controller: "federails/server/published",
        action: "show",
        publishable_type: "posts",
        id: post.id
      })

      stub_request(:get, remote_actor_url).
        to_return(status: 200, body: remote_actor_hash.to_json, headers: { 'Content-Type' => 'application/activity+json' })
      stub_request(:get, local_url).
        to_return(status: 200, body: remote_post_hash.to_json, headers: { 'Content-Type' => 'application/activity+json' })
    end

    context "when activity and actor are successfully dereferenced" do
      it "creates a remote Federails::Actor if it doesn't exist" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to change { Federails::Actor.where(federated_url: remote_actor_url).count }.from(0).to(1)
      end

      it "reuses an existing Federails::Actor" do
        create(:distant_actor, federated_url: remote_actor_url)

        expect {
          described_class.handle_like_activity(activity_hash)
        }.not_to change { Federails::Actor.count }
      end

      it "creates a Federails::Activity record" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to change { Federails::Activity.count }.by(1)
      end

      it "sets the activity action to 'Like'" do
        described_class.handle_like_activity(activity_hash)
        activity = Federails::Activity.last

        expect(activity.action).to eq("Like")
      end

      it "associates the activity with the correct post" do
        described_class.handle_like_activity(activity_hash)
        activity = Federails::Activity.last

        expect(activity.entity).to eq(post)
      end

      it "updates the post likes count" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to change { post.reload.likes_count }.from(0).to(1)
      end

      it "handles a Like activity with an ID string" do
        allow(Fediverse::Request).to receive(:dereference).and_call_original
        allow(Fediverse::Request).to receive(:dereference).with("activity-id-123").and_return(activity_hash)

        expect {
          described_class.handle_like_activity("activity-id-123")
        }.to change { Federails::Activity.count }.by(1)
      end
    end

    context "when the object URL is not a local URL" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_url?).and_return(false)
      end

      it "raises 'Not a local ID' error" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to raise_error("Not a local ID")
      end
    end

    context "when the local URL does not resolve to a post" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "show",
          publishable_type: "articles",  # Different type
          id: 123
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the controller is not correct" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "posts",  # Wrong controller
          action: "show",
          publishable_type: "posts",
          id: post.id
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the action is not show" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "index",  # Wrong action
          publishable_type: "posts",
          id: post.id
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the post does not exist" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "show",
          publishable_type: "posts",
          id: 99999
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_like_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when multiple likes from the same actor are received" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Fediverse::Request).to receive(:dereference).with(remote_actor_url).and_return({
          "id" => remote_actor_url,
          "type" => "Person",
          "name" => "Alice"
        })
      end

      it "creates just one Like activity" do
        expect {
          2.times { described_class.handle_like_activity(activity_hash) }
        }.to(change { Federails::Activity.count }.by(1))
      end
    end
  end
end
