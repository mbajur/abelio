require "rails_helper"

describe Posts::Liker do
  describe "#call" do
    let(:user) { instance_double(User, site: instance_double(Site)) }
    let(:post) { instance_double(Post, federails_actor: instance_double(Federails::Actor)) }
    let(:federails_activity) { instance_double(Federails::Activity) }

    subject(:call_service) { described_class.new(post, user).call }

    before do
      allow(post).to receive(:liked_by?).with(user).and_return(false)
      allow(post).to receive(:like!).with(actor: post.federails_actor).and_return(federails_activity)
      allow(post).to receive(:increment!).with(:likes_count)
      allow(Post).to receive(:transaction).and_yield
      allow(Like).to receive(:create!)
    end

    it "creates a Like record and increments likes_count" do
      call_service

      expect(post).to have_received(:like!).with(actor: post.federails_actor)
      expect(Like).to have_received(:create!).with(
        likeable: post,
        site: user.site,
        user: user,
        federails_activity: federails_activity
      )
      expect(post).to have_received(:increment!).with(:likes_count)
    end

    it "raises if already liked by user" do
      allow(post).to receive(:liked_by?).with(user).and_return(true)
      expect { call_service }.to raise_error("Post already liked by this user")
    end
  end
end
