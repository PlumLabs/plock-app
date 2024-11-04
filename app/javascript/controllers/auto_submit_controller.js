import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/debounce"

// Connects to data-controller="auto-submit"
export default class extends Controller {
  static values = {
    debounce: {type: Number, default: 0},
  }

  initialize() {
    this.submit = debounce(this.submit.bind(this), this.debounceValue)
  }

  submit() {
    this.element.requestSubmit()
  }
}
