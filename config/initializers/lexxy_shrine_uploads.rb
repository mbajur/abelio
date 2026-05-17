module Abelio
  module LexxyShrineUploads
    def lexxy_rich_textarea_tag(name, value = nil, options = {}, &block)
      apply_shrine_upload_options(options)
      super(name, value, options, &block)
    end

    def lexxy_rich_text_area_tag(name, value = nil, options = {}, &block)
      apply_shrine_upload_options(options)
      super(name, value, options, &block)
    end

    private

    def apply_shrine_upload_options(options)
      options = options.deep_dup
      options[:data] ||= {}

      # Keep Lexxy's standard direct upload flow, but point it at Shrine-backed endpoints.
      options[:data][:direct_upload_url] = main_app.lexxy_uploads_path
      options[:data]["direct_upload_url"] = main_app.lexxy_uploads_path
      options[:data][:blob_url_template] ||= main_app.lexxy_medium_blob_path(":signed_id", ":filename")
      options[:data]["blob_url_template"] ||= main_app.lexxy_medium_blob_path(":signed_id", ":filename")
      options[:data][:image_upload_placeholder] = true
      options[:data]["image_upload_placeholder"] = true

      options
    end
  end
end

Rails.application.config.to_prepare do
  unless Lexxy::TagHelper.ancestors.include?(Abelio::LexxyShrineUploads)
    Lexxy::TagHelper.prepend(Abelio::LexxyShrineUploads)
  end
end
