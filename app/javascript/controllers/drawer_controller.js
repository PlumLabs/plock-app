import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "transition"

// Connects to data-controller="drawer"
export default class extends Controller {
  static targets = [ "panel", "backdrop", "closeButton", "container" ]

  close() {
    Promise.all([
      leave(this.panelTarget),
      leave(this.backdropTarget),
      leave(this.closeButtonTarget),
    ]).then(() => {
      this.containerTarget.classList.add("hidden")
    }).catch(() => {
      // Fallback in case the animation fails
      this.containerTarget.classList.add("hidden")
    })
  }

  open() {
    this.containerTarget.classList.remove("hidden");
    enter(this.panelTarget)
    enter(this.backdropTarget)
    enter(this.closeButtonTarget)
  }
}
