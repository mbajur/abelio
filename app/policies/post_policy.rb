class PostPolicy < ApplicationPolicy
  def edit?
    owner? && record.local?
  end

  def save_draft?
    record.local? && !record.published?
  end

  def publish?
    !record.published? && record.local?
  end

  def announce?
    owner? && record.published? && record.local?
  end

  def unannounce?
    owner? && record.announced_in.exists? && record.local?
  end

  private

  def owner?
    user == record.user
  end
end
