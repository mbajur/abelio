module Panel
  class PostsController < PanelController
    def show
      @post = current_user.site.posts.find(params[:id])
    end

    def new
      @post = Post.new
    end

    def create
      @post = current_site.posts.new(post_params)
      @post.postable = Article.new
      @post.user = current_user

      if @post.save
        redirect_to panel_post_path(@post), notice: t(".success")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @post = current_site.posts.local_federails_entities.find(params[:id])
    end

    def update
      @post = current_site.posts.local_federails_entities.find(params[:id])

      if @post.update(post_params)
        @post.publish if params[:publish] == "1"
        redirect_to panel_post_path(@post), notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def announce
      @post = current_site.posts.find(params[:id])
      authorize @post

      Posts::Announcer.new(@post, current_user).call
      load_announced_post_ids!

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: panel_post_path(@post),
                        notice: t(".success")
        end
      end
    end

    def unannounce
      @post = current_site.posts.find(params[:id])
      authorize @post

      @announce = Posts::Unannouncer.new(@post, current_user).call
      load_announced_post_ids!

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: panel_post_path(@post),
                        notice: t(".success")
        end
      end
    end

    def like
      @post = current_site.posts.find(params[:id])
      authorize @post

      Posts::Liker.new(@post, current_user).call
      load_liked_post_ids!

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: panel_post_path(@post),
                        notice: t(".success")
        end
      end
    end

    def unlike
      @post = current_site.posts.find(params[:id])
      authorize @post

      Posts::Unliker.new(@post, current_user).call
      load_liked_post_ids!

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_back fallback_location: panel_post_path(@post),
                        notice: t(".success")
        end
      end
    end

    private

    def post_params
      params.require(:post).permit(:content)
    end
  end
end
