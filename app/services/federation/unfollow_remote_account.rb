class Federation::UnfollowRemoteAccount
  attr_reader :local_actor, :remote_actor

  def initialize(local_actor:, remote_actor:)
    @local_actor = local_actor
    @remote_actor = remote_actor
  end

  def call
    raise ArgumentError, "local_actor is required" if local_actor.blank?
    raise ArgumentError, "remote_actor is required" if remote_actor.blank?

    following = Federails::Following.find_by(actor: local_actor, target_actor: remote_actor)
    return false if following.blank?

    following.destroy!
    true
  end
end
