module Lexxy
  class UploadsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, only: [ :upload ]

    def create
      if params[:blob].present?
        medium = Medium.create!(site: current_site)
        render json: direct_upload_payload(medium, blob_params), status: :created
      else
        file = params[:file]
        return render json: { error: "file is required" }, status: :unprocessable_entity if file.blank?

        medium = Medium.new
        medium.file = file
        medium.site = current_site
        medium.save!

        render json: uploaded_blob_payload(medium)
      end
    end

    def upload
      medium = locate_medium
      return head :not_found unless medium

      filename = params[:filename].presence || "upload"
      content_type = request.headers["Content-Type"].presence || "application/octet-stream"

      io = StringIO.new(request.raw_post)
      io.set_encoding(Encoding::BINARY)

      uploaded_file = MediumFileUploader.new(:store).upload(io, metadata: {
        "filename" => filename,
        "mime_type" => content_type,
        "size" => request.content_length.to_i
      })

      medium.file = uploaded_file
      medium.save!

      head :no_content
    end

    def show
      medium = locate_medium
      return head :not_found unless medium
      return head :not_found unless medium.file.present?

      redirect_to medium.file_url(host: nil)
    end

    private

    def locate_medium
      current_site.media.find_signed!(params[:signed_id], for: "lexxy-medium")
    end

    def blob_params
      params.require(:blob).permit(:filename, :content_type, :byte_size, :checksum, metadata: {})
    end

    def direct_upload_payload(medium, attrs)
      filename = attrs[:filename].presence || "upload"
      content_type = attrs[:content_type].presence || "application/octet-stream"
      byte_size = attrs[:byte_size].to_i
      signed_id = medium.to_sgid(for: "lexxy-medium").to_s
      blob_path = main_app.lexxy_medium_blob_path(signed_id: signed_id, filename: filename)

      {
        signed_id: signed_id,
        attachable_sgid: medium.attachable_sgid,
        filename: filename,
        content_type: content_type,
        byte_size: byte_size,
        previewable: previewable_content_type?(content_type),
        url: blob_path,
        direct_upload: {
          url: blob_path,
          headers: direct_upload_headers(content_type, attrs[:checksum])
        }
      }
    end

    def direct_upload_headers(content_type, checksum)
      headers = { "Content-Type" => content_type }
      headers["Content-MD5"] = checksum if checksum.present?
      headers
    end

    def uploaded_blob_payload(medium)
      metadata = medium.file.metadata || {}
      content_type = metadata["mime_type"] || medium.file.mime_type || "application/octet-stream"
      filename = metadata["filename"] || "upload"
      byte_size = metadata["size"] || 0
      signed_id = medium.to_sgid(for: "lexxy-medium").to_s

      {
        attachable_sgid: medium.attachable_sgid,
        signed_id: signed_id,
        filename: filename,
        content_type: content_type,
        byte_size: byte_size,
        previewable: previewable_content_type?(content_type),
        url: medium.file_url(host: nil)
      }
    end

    def previewable_content_type?(content_type)
      content_type.start_with?("image/")
    end
  end
end
