module Panel
  class SettingsController < PanelController
    def edit
      @site = current_site
    end

    def update
      @site = current_site

      if @site.update(site_params)
        redirect_to edit_panel_settings_path, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def site_params
      params.require(:site).permit(:name, :logo, :summary, :template_id)
    end
  end
end
