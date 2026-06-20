import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
//
// The actual theming is pure CSS (light-dark() tokens switched by `color-scheme`);
// this controller just flips <html data-theme="…"> — which flips color-scheme — and keeps the
// toggle icon in sync.
//
//   - No data-theme attribute        -> :root { color-scheme: light dark } follows the OS.
//   - data-theme="dark" / "light"    -> color-scheme forced, light-dark() resolves to it.
export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]
  static values = { storageKey: String }

  connect() {
    this.media = window.matchMedia("(prefers-color-scheme: dark)")
    this.onMediaChange = () => this.renderIcons()
    this.media.addEventListener("change", this.onMediaChange)
    this.applyStored()
    this.renderIcons()
  }

  disconnect() {
    if (this.media && this.onMediaChange) {
      this.media.removeEventListener("change", this.onMediaChange)
    }
  }

  toggle() {
    const next = this.resolved === "dark" ? "light" : "dark"
    if (this.storageKeyValue) {
      try { localStorage.setItem(this.storageKeyValue, next) } catch (e) {}
    }
    document.documentElement.dataset.theme = next
    this.renderIcons()
  }

  // Reflect a stored explicit choice; otherwise follow the OS (no attribute).
  applyStored() {
    const choice = this.storedChoice
    if (choice) document.documentElement.dataset.theme = choice
    else delete document.documentElement.dataset.theme
  }

  get storedChoice() {
    if (!this.storageKeyValue) return null
    try {
      const v = localStorage.getItem(this.storageKeyValue)
      return v === "light" || v === "dark" ? v : null
    } catch (e) {
      return null
    }
  }

  get resolved() {
    return this.storedChoice || (this.media.matches ? "dark" : "light")
  }

  renderIcons() {
    const dark = this.resolved === "dark"
    this.darkIconTargets.forEach((el) => el.classList.toggle("hidden", !dark))
    this.lightIconTargets.forEach((el) => el.classList.toggle("hidden", dark))
  }
}
