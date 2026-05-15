module Panel
  module Blog
    class PostsController < BlogController
      def index
        @posts = current_site.posts.non_sketches.published.freshly_published_first.includes(:federails_actor)
      end
    end
  end
end
