module Panel
  module Blog
    class DraftsController < BlogController
      def index
        @posts = Post.non_sketches.draft.for_panel_listing
      end
    end
  end
end
