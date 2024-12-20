import { Controller } from "@hotwired/stimulus"
import { leave, toggle } from "transition"

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = [ "menu" ]

  toggle() {
    toggle(this.menuTarget)
  }

  hide(event) {
    const clickedInside = this.element.contains(event.target)
    const isClosed = this.menuTarget.classList.contains("hidden")

    if (!clickedInside && !isClosed) {
      leave(this.menuTarget)
    }
  }
}
