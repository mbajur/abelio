module Posts
  class Announcer
    def initialize(post, user)
      @post = post
      @user = user
    end

    def call
      Post.transaction do
        announce = Post.new
        announce.site = post.site
        announce.user = user
        announce.postable = Announce.new
        announce.announced_post = post
        announce.state = Post.states["published"]
        announce.published_at = Time.current
        announce.save!

        post.announce!
        post.increment!(:announces_count)
      end
    end

    private

    attr_reader :post, :user
  end
end
