module Panel
  module Blog
    class DraftsController < BlogController
      def index
        @posts = Post.non_sketches.draft.includes(:federails_actor)
      end
    end
  end
end
