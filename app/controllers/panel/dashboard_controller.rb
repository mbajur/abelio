module Panel
  class DashboardController < PanelController
    def index
      @posts = Post
        .by_site_and_its_followings(Current.site)
        .non_sketches.published.freshly_published_first
    end
  end
end
