require "rails_helper"

describe Posts::Unliker do
  describe "#call" do
    let(:user) { instance_double(User) }
    let(:post) { instance_double(Post) }
    let(:likes_association) { instance_double(ActiveRecord::Associations::CollectionProxy) }
    let(:federails_activity) { instance_double(Federails::Activity, undo!: true) }
    let(:like) { instance_double(Like, federails_activity: federails_activity, destroy!: true) }

    subject(:call_service) { described_class.new(post, user).call }

    before do
      allow(Post).to receive(:transaction).and_yield
      allow(post).to receive(:likes).and_return(likes_association)
      allow(likes_association).to receive(:find_by).with(user: user).and_return(like)
      allow(post).to receive(:decrement!).with(:likes_count)
    end

    it "destroys the Like record and decrements likes_count" do
      call_service

      expect(likes_association).to have_received(:find_by).with(user: user)
      expect(like).to have_received(:destroy!)
      expect(federails_activity).to have_received(:undo!)
      expect(post).to have_received(:decrement!).with(:likes_count)
    end
  end
end
