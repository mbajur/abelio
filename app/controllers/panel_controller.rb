class PanelController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :load_announced_post_ids!

  private

  def set_current_site_following_actor_ids
    Current.site_following_actor_ids = Current.site ? Current.site.federails_actor.follows.pluck(:id) : []
  end

  def load_announced_post_ids!
    @announced_post_ids = current_site.posts.where(postable_type: "Announce").pluck(:announced_post_id)
  end

  def load_liked_post_ids!(post_ids = [])
    @liked_post_ids = current_site.likes.where(user: current_user, likeable_type: "Post", likeable_id: post_ids).pluck(:likeable_id)
  end
end
