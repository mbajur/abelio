class Site < ApplicationRecord
  include Federails::ActorEntity
  include SiteLogoUploader::Attachment(:logo)

  after_create :create_federails_actor
  after_update :create_federails_actor!
  after_update :create_update_activity

  acts_as_federails_actor username_field: :domain,
                          name_field: :name

  has_many :media, class_name: "Medium", dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  belongs_to :template

  validates :name, presence: true

  def to_activitypub_object
    data = {
      summary: summary
    }

    if logo.present?
      data[:icon] = {
        type: "Image",
        url: logo_url,
        "mediaType" => logo.mime_type
      }
    end

    data
  end

  private

  # Creates the actor or destroys it, depending on the condition
  def create_federails_actor!
    create_federails_actor
  end

  def create_update_activity
    Federails::Activity.create! actor: self.federails_actor, action: "Update", entity: self, to: nil
  end
end
