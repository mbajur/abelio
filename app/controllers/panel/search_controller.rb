module Panel
  class SearchController < PanelController
    def index
      @mode, @result = Search.new(params[:q]).call
    end
  end
end
