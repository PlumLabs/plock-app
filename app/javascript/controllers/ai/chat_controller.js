import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai--chat"
export default class extends Controller {
  static targets = [ "aiMessages" ]

  connect() {
    this.setScrollPosition()
    this.messageObserver = new MutationObserver(() => this.setScrollPosition())
    this.messageObserver.observe(this.aiMessagesTarget, { childList: true, subtree: true })
  }

  disconnect() {
    this.messageObserver?.disconnect()
  }

  setScrollPosition() {
    const messagesContainer = this.aiMessagesTarget
    messagesContainer.scrollTop = messagesContainer.scrollHeight - messagesContainer.clientHeight
  }
}
