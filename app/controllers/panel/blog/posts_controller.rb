module Panel
  module Blog
    class PostsController < BlogController
      def index
        @posts = Post.local_federails_entities.non_sketches.published.freshly_published_first.includes(:federails_actor)
      end
    end
  end
end
