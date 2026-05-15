require "federails/data_transformer/note"

class Post < ApplicationRecord
  include Sketchable
  include Federails::DataEntity

  belongs_to :site
  belongs_to :user, optional: true
  delegated_type :postable, types: %w[Note Article]

  validates :postable, presence: true

  delegate :blocks, to: :postable

  enum :state, {
    initialized: "initialized",
    draft: "draft",
    published: "published",
    sketch: "sketch",
    distant: "distant"
  }

  scope :freshly_published_first, -> { order(published_at: :desc) }

  after_commit :touch_published_at, on: :update, if: -> { saved_change_to_state? && published? }

  def self.from_activitypub_object(hash)
    {
      federated_url: hash["id"],
      content: hash["content"]
    }
  end

  def to_activitypub_object
    # ::Federails::DataTransformer::Note.to_federation self, content: content
    ::Federails::DataTransformer::Note.to_federation self, content: "Hardcoded content" # @todo unhardcode it
  end

  # Live editable posts does not have sketches created on edit. They are being
  # edited directly until they are published. After publishing, they are no
  # longer live editable.
  def live_editable?
    sketch? || draft? || initialized?
  end

  def update_likes_count!
    update! likes_count: Federails::Activity.where(action: "Like", entity: self).count
  end

  def update_announces_count!
    update! announces_count: Federails::Activity.where(action: "Announce", entity: self).count
  end

  def local?
    federated_url.blank?
  end

  private

  def create_federails_activity(action)
    manually_create_federails_activity(action)
  end

  # @todo this is being called when likes counter is updated, it can't work like that
  def manually_create_federails_activity(action)
    # ensure_federails_configuration!
    # return unless local_federails_entity? && send(federails_data_configuration[:should_federate_method])

    # ::Federails::Activity.create! actor: federails_actor, action: action, entity: self
  end

  def touch_published_at
    touch(:published_at)
  end
end
