class TemplatePolicy < ApplicationPolicy
  def delete?
    user.site.template_id != record.id
  end
end
