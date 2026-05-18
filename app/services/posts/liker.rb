module Posts
  class Liker
    def initialize(post, user)
      @post = post
      @user = user
    end

    def call
      raise "Post already liked by this user" if post.liked_by?(user)

      Post.transaction do
        federails_like = post.like!(actor: post.federails_actor)
        Like.create!(likeable: post, site: user.site, user: user, federails_activity: federails_like)
        post.increment!(:likes_count)
      end
    end

    private

    attr_reader :post, :user
  end
end
