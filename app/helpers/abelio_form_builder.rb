class AbelioFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    options[:class] = "border px-3 py-1 w-full #{options[:class]}"
    super(method, options)
  end

  def text_area(method, options = {})
    options[:class] = "w-full border px-3 py-1 #{options[:class]}"
    super(method, options)
  end

  def label(method, text = nil, options = {}, &block)
    options[:class] = "mb-2 block font-semibold #{options[:class]}"
    super(method, text, options, &block)
  end

  def submit(value = nil, options = {})
    options[:class] = "bg-black text-white px-3 py-1 #{options[:class]}"
    super(value, options)
  end

  def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
    html_options[:class] = "border px-3 py-2 w-full #{html_options[:class]}"
    super(method, collection, value_method, text_method, options, html_options)
  end
end
