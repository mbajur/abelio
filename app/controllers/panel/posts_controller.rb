module Panel
  class PostsController < PanelController
    def show
      @post = current_user.site.posts.find(params[:id])
    end

    def new
      if current_site.posts.initialized.any?
        post = current_site.posts.initialized.last
      else
        post = current_site.posts.new
        post.postable = Article.build
        post.user = current_user
        post.postable.blocks.build(blockable: ::Block::ImageSet.new)
        post.postable.blocks.build(blockable: ::Block::RichText.new)
        post.save!
      end

      redirect_to edit_panel_post_path(post)
    end

    def create
      @post = current_site.posts.new(post_params)
      @post.user = current_user

      if @post.save
        redirect_to panel_post_path(@post), notice: t(".success")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @original_post = current_site.posts.find(params[:id])

      if @original_post.live_editable?
        @post = @original_post
      elsif @original_post.sketches.exists?
        @post = @original_post.sketches.last
      else
        @post = current_site.posts.new(
          user: @original_post.user,
          sketch_of: @original_post,
          state: :sketch
        )
        @post.postable = @original_post.postable.dup
        @post.save!
        @post.postable.duplicate_blocks(@original_post.postable.blocks.roots.order(:lft))
      end
    end

    def update
      @post = current_site.posts.find(params[:id])
      @original_post = @post.sketch_of

      Post.transaction do
        if @original_post
          @original_post.postable.blocks.destroy_all
          @post.postable.blocks.update_all(
            resource_id: @original_post.postable.id,
            resource_type: @original_post.postable.class.name
          )
          @post.destroy!
        end

        if params[:create_draft]
          (@original_post || @post).draft!
        else
          (@original_post || @post).published!
        end
      end

      redirect_to panel_post_path(@original_post || @post), notice: t(".success")
    end

    private

    def post_params
      params.require(:post).permit(:content)
    end
  end
end
