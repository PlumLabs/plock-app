module NavigationHelper
  def nav_link_to(name, path, options = {}, &block)
    classes = options[:class] || ""
    active = current_page?(path) || request.path.start_with?(path)
    active_classes = "bg-secondary-hover text-primary-light"
    default_classes = "text-fg-default hover:text-primary-light hover:bg-secondary-hover"

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
