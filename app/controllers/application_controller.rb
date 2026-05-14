class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_current_site

  helper_method :current_site

  private

  def set_current_site
    Current.site = Site.find_by!(domain: request.host)
  end

  def current_site
    Current.site
  end
end
