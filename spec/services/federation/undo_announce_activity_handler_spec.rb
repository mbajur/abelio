require "rails_helper"

describe Federation::UndoAnnounceActivityHandler do
  describe ".handle_undo_announce_request" do
    let(:site) { create(:site) }
    let(:post) { create(:post, site: site) }
    let(:remote_actor) { create(:distant_actor) }

    let(:local_url) { "https://aptest4.mbajur.com/federation/published/posts/#{post.id}" }
    let(:remote_actor_url) { "https://remote.example.com/users/alice" }

    let(:activity_hash) do
      {
        "@context" => "https://www.w3.org/ns/activitystreams",
        "id" => "https://remote.example.com/users/alice/statuses/116556938996951374/activity/undo",
        "type" => "Undo",
        "actor" => remote_actor_url,
        "object" => {
          "id" => "https://remote.example.com/users/alice/statuses/116556938996951374/activity",
          "type" => "Announce",
          "actor" => remote_actor_url,
          "object" => local_url
        },
        "actor_id" => "77e203a6-5c42-4009-a238-cc2d075d2038"
      }
    end

    before do
      allow(Federails::Utils::Host).to receive(:local_url?).and_return(true)
      allow(Federails::Utils::Host).to receive(:local_route).and_return({
        controller: "federails/server/published",
        action: "show",
        publishable_type: "posts",
        id: post.id
      })
      allow(Federails::Actor).to receive(:find_or_create_by_object).with(remote_actor_url).and_return(remote_actor)
    end

    context "when a matching Announce activity exists" do
      let!(:announce_activity) do
        Federails::Activity.create!(actor: remote_actor, entity: post, action: "Announce")
      end

      it "destroys the Announce activity" do
        expect {
          described_class.handle_undo_announce_request(activity_hash)
        }.to change { Federails::Activity.count }.by(-1)
      end

      it "destroys the correct Announce activity" do
        described_class.handle_undo_announce_request(activity_hash)
        expect(Federails::Activity.exists?(announce_activity.id)).to be false
      end

      it "updates the post announces count" do
        post.update!(announces_count: 1)

        expect {
          described_class.handle_undo_announce_request(activity_hash)
        }.to change { post.reload.announces_count }.from(1).to(0)
      end
    end

    context "when no matching Announce activity exists" do
      it "does not raise an error" do
        expect {
          described_class.handle_undo_announce_request(activity_hash)
        }.not_to raise_error
      end

      it "does not change Federails::Activity count" do
        expect {
          described_class.handle_undo_announce_request(activity_hash)
        }.not_to change { Federails::Activity.count }
      end

      it "still updates the post announces count" do
        expect {
          described_class.handle_undo_announce_request(activity_hash)
        }.not_to raise_error
        # announces_count reflects reality (0 Announce activities)
        expect(post.reload.announces_count).to eq(0)
      end
    end

    context "when the object URL is not a local URL" do
      before do
        allow(Federails::Utils::Host).to receive(:local_url?).and_return(false)
      end

      it "raises 'Not a local ID' error" do
        expect {
          described_class.handle_undo_announce_request(activity_hash)
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
          described_class.handle_undo_announce_request(activity_hash)
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
          described_class.handle_undo_announce_request(activity_hash)
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
          described_class.handle_undo_announce_request(activity_hash)
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
          described_class.handle_undo_announce_request(activity_hash)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
