require "rails_helper"

describe Federation::AnnounceActivityHandler do
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

    around do |example|
      original_site = Current.site

      Current.site = site
      example.run
      Current.site = original_site
    end

    before do
      allow(Federails::Utils::Object).to receive(:find_or_initialize!).and_call_original
      allow(Federails::Utils::Object).to receive(:find_or_initialize!).with(local_url).and_return(post)

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

      it "creates an Announce post for the activity" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to change { Post.where(postable_type: "Announce").count }.by(1)

        announce_post = Post.find_by!(federated_url: activity_hash["id"])
        expect(announce_post.state).to eq("distant")
        expect(announce_post.federails_actor.federated_url).to eq(remote_actor_url)
        expect(announce_post.postable.announced_post).to eq(post)
      end

      it "does not create a duplicate Announce activity for the same actor and post" do
        expect {
          2.times { described_class.handle_announce_activity(activity_hash) }
        }.to change { Federails::Activity.count }.by(1)
      end

      it "does not create duplicate announce posts for the same activity" do
        expect {
          2.times { described_class.handle_announce_activity(activity_hash) }
        }.to change { Post.where(postable_type: "Announce").count }.by(1)
      end

      it "handles an Announce activity passed as an ID string" do
        allow(Fediverse::Request).to receive(:dereference).and_call_original
        allow(Fediverse::Request).to receive(:dereference).with("activity-id-789").and_return(activity_hash)

        expect {
          described_class.handle_announce_activity("activity-id-789")
        }.to change { Federails::Activity.count }.by(1)
      end
    end

    context "when the announced object is remote" do
      let(:remote_object_url) { "https://remote.example.com/@bob/112233" }
      let(:remote_announced_post) { create(:post, state: :distant, federated_url: remote_object_url) }

      let(:activity_hash) do
        super().merge(
          "id" => "https://remote.example.com/users/alice/statuses/123/activity",
          "object" => remote_object_url
        )
      end

      before do
        allow(Federails::Utils::Object).to receive(:find_or_initialize!).with(remote_object_url).and_return(remote_announced_post)
      end

      it "creates an Announce activity and post for the remote announced post" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to change { Federails::Activity.count }.by(1)
          .and change { Post.where(postable_type: "Announce").count }.by(1)

        expect(Federails::Activity.last.entity).to eq(remote_announced_post)
        expect(Post.find_by(federated_url: activity_hash["id"]).postable.announced_post).to eq(remote_announced_post)
      end
    end

    context "when announced object cannot be resolved to a Post" do
      before do
        non_post_entity = create(:site)
        allow(Federails::Utils::Object).to receive(:find_or_initialize!).with(local_url).and_return(non_post_entity)
      end

      it "raises ActiveRecord::RecordNotFound" do
        expect {
          described_class.handle_announce_activity(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
