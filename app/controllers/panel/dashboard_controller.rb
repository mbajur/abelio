module Panel
  class DashboardController < PanelController
    def index
      followed_actor_ids = Federails::Following.where(actor: current_site.federails_actor).select(:target_actor_id)

      local_published_posts = Post.where(site: current_site).published
      followed_distant_posts = Post.where(federails_actor_id: followed_actor_ids).distant

      @posts = local_published_posts
        .or(followed_distant_posts)
        .includes(:federails_actor, :announced_post)
        .freshly_published_first
    end
  end
end
