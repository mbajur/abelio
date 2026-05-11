require "rails_helper"

describe Federation::UndoLikeActivityHandler do
  describe ".handle_undo_like_request" do
    let(:site) { create(:site) }
    let(:post) { create(:post, site: site) }
    let(:remote_actor) { create(:distant_actor) }

    let(:local_url) { "http://example.com/federails/server/published/posts/#{post.id}" }
    let(:remote_actor_url) { "https://remote.example.com/users/alice" }

    let(:activity_hash) do
      {
        "id" => "https://remote.example.com/users/alice/undos/456",
        "type" => "Undo",
        "actor" => remote_actor_url,
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
        .to_return(status: 200, body: { "id" => local_url }.to_json, headers: { "Content-Type" => "application/activity+json" })
    end

    context "when a matching Like activity exists" do
      let!(:like_activity) do
        Federails::Activity.create!(actor: remote_actor, entity: post, action: "Like")
      end

      before do
        allow(Federails::Actor).to receive(:find_or_create_by_object).with(remote_actor_url).and_return(remote_actor)
      end

      it "destroys the Like activity" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.to change { Federails::Activity.count }.by(-1)
      end

      it "destroys the correct Like activity" do
        described_class.handle_undo_like_request(activity_hash)
        expect(Federails::Activity.exists?(like_activity.id)).to be false
      end

      it "updates the post likes count" do
        post.update!(likes_count: 1)
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.to change { post.reload.likes_count }.from(1).to(0)
      end

      it "handles an Undo activity passed as an ID string" do
        allow(Fediverse::Request).to receive(:dereference).and_call_original
        allow(Fediverse::Request).to receive(:dereference).with("activity-id-456").and_return(activity_hash)

        expect {
          described_class.handle_undo_like_request("activity-id-456")
        }.to change { Federails::Activity.count }.by(-1)
      end
    end

    context "when no matching Like activity exists" do
      before do
        allow(Federails::Actor).to receive(:find_or_create_by_object).with(remote_actor_url).and_return(remote_actor)
      end

      it "does not raise an error" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.not_to raise_error
      end

      it "does not change Federails::Activity count" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.not_to change { Federails::Activity.count }
      end

      it "still updates the post likes count" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.not_to raise_error
        # likes_count reflects reality (0 Like activities)
        expect(post.reload.likes_count).to eq(0)
      end
    end

    context "when the object URL is not a local URL" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_url?).and_return(false)
      end

      it "raises 'Not a local ID' error" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.to raise_error("Not a local ID")
      end
    end

    context "when the local URL does not resolve to a post" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "show",
          publishable_type: "articles",
          id: 123
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the controller is not correct" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "posts",
          action: "show",
          publishable_type: "posts",
          id: post.id
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the action is not show" do
      before do
        allow(Fediverse::Request).to receive(:dereference).and_return(activity_hash)
        allow(Federails::Utils::Host).to receive(:local_route).and_return({
          controller: "federails/server/published",
          action: "index",
          publishable_type: "posts",
          id: post.id
        })
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_undo_like_request(activity_hash)
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
          described_class.handle_undo_like_request(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
