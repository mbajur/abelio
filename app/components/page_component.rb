# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  renders_many :actions
  renders_one :sidebar
  renders_one :subtitle

  def initialize(title: nil, main_classes: "col-span-8")
    @title = title
    @main_classes = main_classes
  end

  def main_classes
    helpers.class_names("p-4", @main_classes, 'border-x': sidebar?, 'border-l': !sidebar?)
  end
end
