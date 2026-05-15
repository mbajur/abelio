module RailsApiLogger
  class InboundRequestLogsController < ApplicationController
    include Pagy::Method

    layout "rails_api_logger"

    def index
      @pagy, @inbound_request_logs = pagy(InboundRequestLog.order(created_at: :desc))
    end

    def show
      @inbound_request_log = InboundRequestLog.find(params[:id])
    end
  end
end
