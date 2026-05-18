require "rails_helper"

describe Posts::Announcer do
  describe "#call" do
    let(:site) { create(:site) }
    let(:user) { create(:user, site: site) }
    let(:post) { create(:post, site: site) }

    subject(:call_service) { described_class.new(post, user).call }

    before do
      allow(post).to receive(:announce!)
    end

    it "creates a new announce post for the user and target post" do
      expect { call_service }.to change { Post.count }.by(1)

      announce = Post.where(user: user, announced_post: post).order(:id).last

      expect(announce).to be_present
      expect(announce.site).to eq(post.site)
      expect(announce.postable).to be_a(Announce)
      expect(announce).to be_published
      expect(announce.published_at).to be_present
      expect(post).to have_received(:announce!)
    end

    it "increments announces count on the announced post" do
      expect { call_service }.to change { post.reload.announces_count }.from(0).to(1)
    end

    it "always creates a new announce even if one already exists" do
      create(
        :post,
        site: site,
        user: user,
        postable: Announce.create!,
        announced_post: post,
        state: :published
      )

      expect { call_service }.to change { Post.where(user: user, announced_post: post).count }.by(1)
    end
  end
end
