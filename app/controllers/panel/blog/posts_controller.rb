module Panel
  module Blog
    class PostsController < BlogController
      def index
        @posts = current_site.posts.non_sketches.published.for_panel_listing
      end
    end
  end
end
