module Posts
  class Unannouncer
    def initialize(post, user)
      @post = post
      @user = user
    end

    def call
      Post.transaction do
        announce = Post.local_federails_entities.where(announced_post: post).last
        post.federails_activities.where(action: "Announce").last.undo!

        announce.destroy!
        post.decrement!(:announces_count)

        announce
      end
    end

    private

    attr_reader :post, :user
  end
end
