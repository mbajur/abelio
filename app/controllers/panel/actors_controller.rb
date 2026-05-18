module Panel
  class ActorsController < PanelController
    include Pagy::Method

    before_action :set_current_site_following_actor_ids

    def show
      @actor = find_actor

      @pagy, @posts = pagy(Post.where(federails_actor: @actor).for_panel_listing)
    end

    def follow
      actor = find_actor
      Federation::FollowRemoteAccount.new(local_actor: Current.site.federails_actor, remote_actor: actor).call

      redirect_back fallback_location: panel_actor_path(params[:id]), notice: "You are now following #{actor.name}."
    end

    def unfollow
      actor = find_actor
      Federation::UnfollowRemoteAccount.new(local_actor: Current.site.federails_actor, remote_actor: actor).call

      redirect_back fallback_location: panel_actor_path(params[:id]), notice: "You have unfollowed #{actor.name}."
    end

    private

    def find_actor
      actor = Federails::Actor.find_by_account(params[:id])
      raise ActiveRecord::RecordNotFound if actor.nil?

      actor
    end
  end
end
