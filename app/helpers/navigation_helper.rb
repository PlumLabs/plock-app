module NavigationHelper
  def nav_link_to(name, path, options = {}, &block)
    classes = options[:class] || ""
    active = current_page?(path) || request.path.start_with?(path)
    active_classes = "bg-gray-50 text-indigo-600"
    default_classes = "text-gray-700 hover:text-indigo-600 hover:bg-gray-50"

    link_classes = "#{classes} #{active ? active_classes : default_classes}"

    link_to(path, class: link_classes.strip) do
      if block_given?
        yield
      else
        name
      end
    end
  end
end
