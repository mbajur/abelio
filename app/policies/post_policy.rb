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
    record.published?
  end

  def unannounce?
    record.local? && record.announced_in.where(user: user).exists?
  end

  def like?
    record.published?
  end

  def unlike?
    record.local? && record.likes.where(user: user).exists?
  end

  private

  def owner?
    user == record.user
  end
end
