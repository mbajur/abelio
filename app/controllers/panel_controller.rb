class PanelController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!
end
