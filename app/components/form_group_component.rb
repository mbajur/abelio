# frozen_string_literal: true

class FormGroupComponent < ViewComponent::Base
  renders_one :form
  renders_one :preview

  def initialize(key:, label: nil, editable: false)
    @key = key
    @label = label || key.to_s.humanize
    @editable = editable
  end

  private

  def turbo_frame_id
    "edit_#{@key}_frame"
  end

  def preview_classes
    @editable ? "col-span-5" : "col-span-6"
  end
end
