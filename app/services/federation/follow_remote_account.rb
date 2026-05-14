class Federation::FollowRemoteAccount
  attr_reader :local_actor, :remote_actor

  def initialize(local_actor:, remote_actor:)
    @local_actor = local_actor
    @remote_actor = remote_actor
  end

  def call
    Federails::Following.create! actor: local_actor, target_actor: remote_actor
  end
end
