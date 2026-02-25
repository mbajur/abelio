class User < ApplicationRecord
  include Federails::ActorEntity

  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :site

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  acts_as_federails_actor username_field: :username, name_field: :username

  after_create :create_federails_actor
  after_update :create_federails_actor!

  def username
    email_address.split("@").first
  end

  private

  # Creates the actor or destroys it, depending on the condition
  def create_federails_actor!
    create_federails_actor
  end
end
