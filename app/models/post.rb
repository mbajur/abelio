require "federails/data_transformer/note"

class Post < ApplicationRecord
  include Sketchable
  include Federails::DataEntity

  belongs_to :site
  belongs_to :user, optional: true
  belongs_to :announced_post, class_name: "Post", foreign_key: "announced_post_id", optional: true
  has_many :announced_in, class_name: "Post", foreign_key: "announced_post_id", dependent: :destroy
  has_many :federails_activities, as: :entity, class_name: "Federails::Activity"
  delegated_type :postable, types: %w[Note Article Announce]

  has_rich_text :content

  validates :postable, presence: true

  enum :state, {
    draft: "draft",
    published: "published",
    sketch: "sketch",
    distant: "distant"
  }, default: "draft"

  scope :freshly_published_first, -> { order(published_at: :desc) }

  after_commit :touch_published_at, on: :update, if: -> { saved_change_to_state? && published? }

  def self.from_activitypub_object(hash)
    {
      federated_url: hash["id"],
      content: hash["content"]
    }
  end

  def announced_by?(user)
    announced_in.exists?(user: user)
  end

  def to_activitypub_object
    # ::Federails::DataTransformer::Note.to_federation self, content: content
    ::Federails::DataTransformer::Note.to_federation self, content: "Hardcoded content" # @todo unhardcode it
  end

  def publish
    update!(published_at: Time.current, state: "published")
  end

  # Live editable posts does not have sketches created on edit. They are being
  # edited directly until they are published. After publishing, they are no
  # longer live editable.
  def live_editable?
    sketch? || draft?
  end

  # @todo we don't want that to update inbox about the change nor create Update activity
  def update_likes_count!
    update! likes_count: federails_activities.where(action: "Like", entity: self).count
  end

  # @todo we don't want that to update inbox about the change nor create Update activity
  def update_announces_count!
    update! announces_count: announced_in.count
  end

  def local?
    attributes["federated_url"].blank?
  end

  private

  # def create_federails_activity(action)
  #   manually_create_federails_activity(action)
  # end

  # @todo this is being called when likes counter is updated, it can't work like that
  def manually_create_federails_activity(action)
    # ensure_federails_configuration!
    # return unless local_federails_entity? && send(federails_data_configuration[:should_federate_method])

    # ::Federails::Activity.create! actor: federails_actor, action: action, entity: self
  end

  def touch_published_at
    touch(:published_at)
  end

  def default_should_federate?
    !postable_type.in?(%w[Announce])
  end
end
