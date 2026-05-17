require "rails_helper"

RSpec.describe "Lexxy::UploadsController", type: :request do
  let(:site) { create(:site) }
  let(:user) { create(:user, site: site) }

  before do
    host! site.domain
  end

  describe "POST /lexxy/uploads" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        post lexxy_uploads_path, params: {
          blob: {
            filename: "image.png",
            content_type: "image/png",
            byte_size: 123,
            checksum: "abc123"
          }
        }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated" do
      before do
        stub_authenticated_request(user)
      end

      it "creates a medium and returns direct upload payload for blob params" do
        expect do
          post lexxy_uploads_path, params: {
            blob: {
              filename: "image.png",
              content_type: "image/png",
              byte_size: 123,
              checksum: "abc123"
            }
          }
        end.to change { Medium.where(site: site).count }.by(1)

        expect(response).to have_http_status(:created)

        body = JSON.parse(response.body)
        medium = Medium.where(site: site).order(:created_at).last

        signed_medium = GlobalID::Locator.locate_signed(body["signed_id"], for: "lexxy-medium")

        expect(signed_medium).to eq(medium)
        expect(body["attachable_sgid"]).to eq(medium.attachable_sgid)
        expect(body["filename"]).to eq("image.png")
        expect(body["content_type"]).to eq("image/png")
        expect(body["byte_size"]).to eq(123)
        expect(body["previewable"]).to eq(true)
        expect(body["url"]).to eq(lexxy_medium_blob_path(signed_id: body["signed_id"], filename: "image.png"))
        expect(body["direct_upload"]["url"]).to eq(lexxy_medium_blob_path(signed_id: body["signed_id"], filename: "image.png"))
        expect(body["direct_upload"]["headers"]).to eq(
          {
            "Content-Type" => "image/png",
            "Content-MD5" => "abc123"
          }
        )
      end

      it "returns validation error when file param is missing" do
        post lexxy_uploads_path

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq("error" => "file is required")
      end

      it "uploads an incoming file and returns uploaded blob payload" do
        fixture_path = Rails.root.join("spec/fixtures/files/upload.png")
        file = Rack::Test::UploadedFile.new(fixture_path, "image/png")

        expect do
          post lexxy_uploads_path, params: { file: file }
        end.to change { Medium.where(site: site).count }.by(1)

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        medium = Medium.where(site: site).order(:created_at).last

        signed_medium = GlobalID::Locator.locate_signed(body["signed_id"], for: "lexxy-medium")

        expect(signed_medium).to eq(medium)
        expect(body["attachable_sgid"]).to eq(medium.attachable_sgid)
        expect(body["filename"]).to eq("upload.png")
        expect(body["content_type"]).to eq("image/png")
        expect(body["byte_size"]).to eq(File.size(fixture_path))
        expect(body["previewable"]).to eq(true)
        expect(body["url"]).to eq(medium.file_url(host: nil))
      end
    end
  end

  describe "PUT /lexxy/media/:signed_id/:filename" do
    let(:medium) { Medium.create!(site: site, file_data: nil) }
    let(:signed_id) { medium.to_sgid(for: "lexxy-medium").to_s }

    context "when unauthenticated" do
      it "redirects to sign in" do
        put lexxy_medium_blob_path(signed_id: signed_id, filename: "upload.bin"),
          params: "abc",
          headers: { "CONTENT_TYPE" => "application/octet-stream" }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated" do
      before do
        stub_authenticated_request(user)
      end

      it "stores raw request body into medium file and returns no content" do
        put lexxy_medium_blob_path(signed_id: signed_id, filename: "avatar.png"),
          params: "abc",
          headers: { "CONTENT_TYPE" => "image/png" }

        expect(response).to have_http_status(:no_content)

        medium.reload

        expect(medium.file).to be_present
        expect(medium.file.metadata["filename"]).to eq("avatar.png")
        expect(medium.file.metadata["mime_type"]).to eq("image/png")
        expect(medium.file.metadata["size"]).to eq(3)
      end
    end
  end

  describe "GET /lexxy/media/:signed_id/:filename" do
    let(:medium) { Medium.create!(site: site, file_data: nil) }
    let(:signed_id) { medium.to_sgid(for: "lexxy-medium").to_s }

    context "when unauthenticated" do
      it "redirects to sign in" do
        get lexxy_medium_blob_path(signed_id: signed_id, filename: "upload.bin")

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when authenticated" do
      before do
        stub_authenticated_request(user)
      end

      it "redirects to file URL when file exists" do
        fixture_path = Rails.root.join("spec/fixtures/files/upload.png")
        uploaded_file = MediumFileUploader.new(:store).upload(
          StringIO.new(File.binread(fixture_path)),
          metadata: {
            "filename" => "upload.png",
            "mime_type" => "image/png",
            "size" => File.size(fixture_path)
          }
        )
        medium.update!(file: uploaded_file)

        get lexxy_medium_blob_path(signed_id: signed_id, filename: "upload.png")

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(medium.file_url(host: nil))
      end

      it "returns not found when medium has no file" do
        get lexxy_medium_blob_path(signed_id: signed_id, filename: "upload.bin")

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  def stub_authenticated_request(user)
    session = instance_double(Session, user: user)

    allow_any_instance_of(ApplicationController).to receive(:resume_session).and_return(session)
  end
end
