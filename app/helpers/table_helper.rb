module TableHelper
  def filter_link_to(name, path_helper, query, options = {}, &block)
    q_params = params.fetch(:q, {}).to_unsafe_h
    combined_params = q_params.merge(query)

    url = send(path_helper, q: combined_params)

    classes = options[:class] || ""
    active = q_params[query.keys.first] == query.values.first.to_s
    active_classes = "text-indigo-600" if active
    link_classes = "#{classes} #{active_classes}".strip

    data = options[:data] || {}

    link_to(url, class: link_classes.strip, data: data) do
      if block_given?
        yield
      else
        name
      end
    end
  end
end
