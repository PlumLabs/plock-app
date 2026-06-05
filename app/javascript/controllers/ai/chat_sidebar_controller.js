import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai--chat-sidebar"
//
// Reloads the sidebar list whenever the URL changes (clicking +, sending the
// first message that creates a chat, opening a chat, or back/forward), passing
// the active chat id so the server can render the list fresh and highlighted.
export default class extends Controller {
  static targets = [ "frame" ]
  static values = { url: String }

  connect() {
    this.refresh = this.refresh.bind(this)
    this.lastPath = window.location.pathname

    document.addEventListener("turbo:frame-load", this.refresh)
    document.addEventListener("turbo:load", this.refresh)
    window.addEventListener("popstate", this.refresh)
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.refresh)
    document.removeEventListener("turbo:load", this.refresh)
    window.removeEventListener("popstate", this.refresh)
  }

  refresh() {
    const path = window.location.pathname
    if (path === this.lastPath) return // URL didn't actually change
    this.lastPath = path

    const match = path.match(/\/ai\/chats\/(\d+)/)
    const active = match ? `?active=${match[1]}` : ""

    // Assigning src re-fetches the frame; the guard above prevents the
    // resulting turbo:frame-load from triggering an infinite reload.
    this.frameTarget.src = `${this.urlValue}${active}`
  }
}
