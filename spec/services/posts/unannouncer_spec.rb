require "rails_helper"

describe Posts::Unannouncer do
  describe "#call" do
    let(:site) { create(:site) }
    let(:user) { create(:user, site: site) }
    let(:post) { create(:post, site: site) }
    let!(:announce) do
      create(
        :post,
        site: site,
        user: user,
        postable: Announce.create!,
        announced_post: post,
        state: :published
      )
    end

    subject(:call_service) { described_class.new(post, user).call }

    before do
      post.update_announces_count!

      activity = instance_double("Federails::Activity", undo!: true)
      relation = instance_double("ActiveRecord::Relation")

      allow(post).to receive(:federails_activities).and_return(relation)
      allow(relation).to receive(:where).with(action: "Announce", actor: post.federails_actor).and_return(relation)
      allow(relation).to receive(:last).and_return(activity)
    end

    it "destroys the announce post" do
      announce_id = announce.id

      expect { call_service }.to change { Post.exists?(announce_id) }.from(true).to(false)
    end

    it "decrements announces count on the announced post" do
      expect { call_service }.to change { post.reload.announces_count }.from(1).to(0)
    end

    it "returns the destroyed announce post instance" do
      result = call_service

      expect(result).to eq(announce)
      expect(result).to be_destroyed
    end
  end
end
