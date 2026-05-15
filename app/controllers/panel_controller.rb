class PanelController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!

  private

  def set_current_site_following_actor_ids
    Current.site_following_actor_ids = Current.site ? Current.site.federails_actor.follows.pluck(:id) : []
  end
end
