class Federation::UnfollowRemoteAccount
  attr_reader :local_actor, :remote_actor

  def initialize(local_actor:, remote_actor:)
    @local_actor = local_actor
    @remote_actor = remote_actor
  end

  def call
    following = Federails::Following.find_by(actor: local_actor, target_actor: remote_actor)
    return false if following.blank?

    following.destroy!
    true
  end
end
