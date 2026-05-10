class Site < ApplicationRecord
  include Federails::ActorEntity
  include SiteLogoUploader::Attachment(:logo)

  after_create :create_federails_actor
  after_update :create_federails_actor!

  acts_as_federails_actor username_field: :domain,
                          name_field: :name

  has_many :posts, dependent: :destroy
  belongs_to :template

  validates :name, presence: true

  private

  # Creates the actor or destroys it, depending on the condition
  def create_federails_actor!
    create_federails_actor
  end
end
