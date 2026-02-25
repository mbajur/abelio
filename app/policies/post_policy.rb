class PostPolicy < ApplicationPolicy
  def edit?
    user == record.user
  end

  def create_draft?
    record.initialized?
  end
end
