module Panel
  module Blog
    class PostsController < BlogController
      def index
        @posts = current_site.posts.non_sketches.published.for_panel_listing
        load_liked_post_ids!(@posts.map(&:id))
      end
    end
  end
end
