import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai--chat-sidebar"
export default class extends Controller {
  static targets = [ "link" ]
  static classes = [ "active" ]

  connect() {}

  select(event) {
    this.activate(event.currentTarget)
  }

  activate(activeLink) {
    this.linkTargets.forEach((link) => {
      const isActive = link === activeLink

      link.classList.toggle(this.activeClass, isActive)

      // aria-current for accessibility
      if (isActive) {
        link.setAttribute("aria-current", "page")
      } else {
        link.removeAttribute("aria-current")
      }
    })
  }
}
