module Panel
  class BlocksController < PanelController
    def create
      @post = Post.find(params[:post_id])
      @block = @post.postable.blocks.new

      case params[:blockable_type]
      when "Block::RichText"
        @block.blockable = ::Block::RichText.new
      when "Block::ImageSet"
        @block.blockable = ::Block::ImageSet.new
      else
        throw "Unknown blockable type: #{params[:blockable_type]}"
      end

      if @block.save
        render :create, status: :created
      else
        redirect_to edit_panel_post_path(@post), alert: t(".failure"), status: :unprocessable_entity
      end
    end

    def update
      @block = ::Block.find(params[:id])

      if @block.update(block_params)
        render :update, status: :ok
      else
        render :edit, alert: t(".failure"), status: :unprocessable_entity
      end
    end

    def refresh
      @block = ::Block.find(params[:id])
      render :refresh, status: :ok
    end

    def destroy
      @post = Post.find(params[:post_id])
      @block = @post.postable.blocks.find(params[:id])
      @block.destroy
    end

    private

    def block_params
      params.require(:block).permit(blockable_attributes: [ :content ])
    end
  end
end
