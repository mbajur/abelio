module Panel
  class ActorsController < PanelController
    include Pagy::Method

    def show
      @actor = Federails::Actor.find_by_account(params[:id])
      raise ActiveRecord::RecordNotFound if @actor.nil?

      @pagy, @posts = pagy(Post.where(federails_actor: @actor).freshly_published_first)
    end
  end
end
