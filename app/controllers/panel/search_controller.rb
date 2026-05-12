module Panel
  class SearchController < PanelController
    def index
      @result = Search.new(params[:q]).call
    end
  end
end
