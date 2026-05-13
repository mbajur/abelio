module Abelio
  module FederailsPostableInitializer
    POSTABLE_TYPE_MAP = {
      "Note" => "Note",
      "Article" => "Article"
    }.freeze

    def find_or_initialize(object_or_id)
      entity = super
      return entity unless entity.is_a?(Post)
      return entity unless entity.new_record?
      return entity if entity.postable.present?

      object = object_or_id.is_a?(Hash) ? object_or_id : Fediverse::Request.dereference(object_or_id)
      return entity unless object.is_a?(Hash)

      assign_postable_from_activitypub_object(entity, object)
      entity.raw_data = object
      published_at = object["published"].present? ? Time.zone.parse(object["published"]) : nil
      entity.published_at = [ Time.current, published_at ].compact.min # Do not let this be in the future
      entity.site = Site.first # @todo use Current.site when it will be implemented
      entity
    end

    private

    def assign_postable_from_activitypub_object(entity, object)
      postable_class_name = POSTABLE_TYPE_MAP[object["type"]]
      postable_class = postable_class_name&.safe_constantize
      return unless postable_class

      attributes = {
        content: object["content"],
        summary: object["summary"]
      }
      attributes[:name] = object["name"] if postable_class == Article

      entity.postable = postable_class.new(attributes.compact)
    end
  end
end

Federails::Utils::Object.singleton_class.prepend(Abelio::FederailsPostableInitializer)
