class PostPolicy < ApplicationPolicy
  def edit?
    user == record.user
  end

  def save_draft?
    record.local? && !record.published?
  end

  def publish?
    !record.published? && record.local?
  end

  def announce?
    record.published? || !record.local?
  end
end
