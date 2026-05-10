require "federails/data_transformer/note"

class Post < ApplicationRecord
  include Sketchable

  include Federails::DataEntity
  acts_as_federails_data handles: "Note",
                         actor_entity_method: :site

  belongs_to :site
  belongs_to :user
  has_many :blocks, as: :resource, dependent: :destroy

  accepts_nested_attributes_for :blocks

  enum :state, {
    initialized: "initialized",
    draft: "draft",
    published: "published",
    sketch: "sketch"
  }

  scope :freshly_published_first, -> { order(published_at: :desc) }

  after_commit :touch_published_at, on: :update, if: -> { saved_change_to_state? && published? }

  def to_activitypub_object
    # ::Federails::DataTransformer::Note.to_federation self, content: content
    ::Federails::DataTransformer::Note.to_federation self, content: "Hardcoded content"
  end

  def self.from_activitypub_object(hash)
    {
      content: hash["content"]
    }
  end

  # Live editable posts does not have sketches created on edit. They are being
  # edited directly until they are published. After publishing, they are no
  # longer live editable.
  def live_editable?
    sketch? || draft? || initialized?
  end

  def update_likes_count!
    update! likes_count: Federrails::Activity.where(action: "Like", entity: self).count
  end

  private

  def create_federails_activity(action)
    # manually_create_federails_activity(action)
  end

  def manually_create_federails_activity(action)
    ensure_federails_configuration!
    return unless local_federails_entity? && send(federails_data_configuration[:should_federate_method])

    ::Federails::Activity.create! actor: federails_actor, action: action, entity: self
  end

  def touch_published_at
    touch(:published_at)
  end
end
