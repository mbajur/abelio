module Posts
  class Unliker
    def initialize(post, user)
      @post = post
      @user = user
    end

    def call
      Post.transaction do
        like = post.likes.find_by(user: user)
        like.destroy!
        like.federails_activity.undo!
        post.decrement!(:likes_count)
      end
    end

    private

    attr_reader :post, :user
  end
end
