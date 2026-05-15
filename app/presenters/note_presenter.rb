class NotePresenter < BasePresenter
  Media = Struct.new(:url, :preview_url, :type, :width, :height)

  def content
    local? ? "Render blocks" : record.content
  end

  def media
    if local?
      []
    else
      attachments = Array.wrap(record.post.raw_data["attachment"])

      attachments.filter_map do |attachment|
        next unless attachment.is_a?(Hash)

        Media.new(
          attachment["url"],
          attachment["url"],
          attachment["mediaType"],
          attachment["width"],
          attachment["height"]
        )
      end
    end
  end

  private

  def local?
    record.post.local?
  end
end
