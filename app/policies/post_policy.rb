class PostPolicy < ApplicationPolicy
  def edit?
    user == record.user
  end

  def save_draft?
    record.local? && record.initialized?
  end

  def publish?
    !record.published? && record.local?
  end
end
