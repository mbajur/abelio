class PostPolicy < ApplicationPolicy
  def edit?
    user == record.user
  end

  def save_draft?
    user == record.user && record.local? && !record.published?
  end

  def publish?
    user == record.user && !record.published? && record.local?
  end
end
