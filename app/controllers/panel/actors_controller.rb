module Panel
  class ActorsController < PanelController
    def show
      @actor = Federails::Actor.find_by_account(params[:id])

      @posts = Post.where(federails_actor: @actor).freshly_published_first.page(params[:page])
    end
  end
end
