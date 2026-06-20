module DesignSystemDocsHelper
  # Code snippets shown next to each live example.
  #
  # These live in a plain Ruby file (not an .erb view) on purpose: ERB cannot
  # contain a literal "%>" inside a tag's Ruby code without prematurely closing
  # the tag, and several snippets need to display ERB like `<%= render ... %>`.
  SNIPPETS = {
    buttons_text: <<~HTML,
      <button class="btn-primary">Primary</button>
      <button class="btn-secondary">Secondary</button>
      <button class="btn-danger">Danger</button>
      <button class="btn-danger-solid">Danger solid</button>
    HTML

    buttons_icon: <<~HTML,
      <button class="btn-icon-primary"><svg>…</svg></button>
      <button class="btn-icon-secondary"><svg>…</svg></button>
    HTML

    badges: <<~HTML,
      <span class="badge badge-success">Success</span>
      <span class="badge badge-danger">Danger</span>
      <span class="badge badge-warning">Warning</span>
      <span class="badge badge-brand">Brand</span>
      <span class="badge badge-neutral">Neutral</span>
    HTML

    form_inputs: <<~HTML,
      <label class="form-label" for="name">Name</label>
      <input class="form-input" type="text" id="name" placeholder="Acme Inc.">

      <label class="form-label" for="role">Role</label>
      <select class="form-select" id="role">
        <option>Admin</option>
        <option>Member</option>
      </select>
    HTML

    form_error_summary: <<~HTML,
      <%= render "alerts/error_summary", errors: @record.errors.full_messages %>
    HTML

    alert_success: <<~HTML,
      <% content_for :alert do %>
        <%= render "alerts/flash", type: :success, title: "Saved!", description: "Your changes were saved." %>
      <% end %>
    HTML

    alert_error: <<~HTML,
      <% content_for :alert do %>
        <%= render "alerts/flash", type: :error, title: "Something went wrong", description: "Please try again." %>
      <% end %>
    HTML

    dropdown: <<~HTML,
      <%= render layout: "dropdowns/select", locals: { placeholder: "Choose a client" } do %>
        <a href="#" class="block px-3 py-2 text-sm text-fg-default hover:bg-secondary-hover">Acme Inc.</a>
        <a href="#" class="block px-3 py-2 text-sm text-fg-default hover:bg-secondary-hover">Globex</a>
      <% end %>
    HTML

    drawer: <<~HTML,
      <%= turbo_frame_tag "upsert_member" do %>
        <%= render layout: "drawers/simple", locals: { title: "Add member" } do %>
          <!-- drawer body -->
        <% end %>
      <% end %>
    HTML

    pagination: <<~HTML,
      <%= render "pagination/simple", controller: :clients %>
    HTML

    typography: <<~HTML
      <h1 class="text-2xl font-bold text-fg-default">Heading</h1>
      <p class="text-sm text-fg-default">Body text uses text-fg-default.</p>
      <p class="text-sm text-fg-muted">Secondary text uses text-fg-muted.</p>
    HTML
  }.freeze

  def ds_code(key)
    SNIPPETS.fetch(key)
  end
end
