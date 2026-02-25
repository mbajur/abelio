module Panel
  class Block::ImagesController < PanelController
    def create
      @parent = ::Block.find(block_params[:parent_id])
      blockable = ::Block::Image.new(block_params[:blockable_attributes])
      @block = ::Block.new(parent: @parent, blockable: blockable, resource: @parent.resource)

      if @block.save
        render :create, status: :created
      else
        render :edit, alert: t(".failure"), status: :unprocessable_entity
      end
    end

    def destroy
      @block = ::Block.find(params[:id])
      @parent = @block.parent
      @block.destroy
      @parent.reload
    end

    private

    def block_params
      params.require(:block).permit(:parent_id, blockable_attributes: [ :id, :file ])
    end
  end
end
