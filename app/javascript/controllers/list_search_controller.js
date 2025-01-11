import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/debounce"

// Connects to data-controller="list-search"
export default class extends Controller {
  static targets = ["input", "item"];

  connect() {
    this.search = debounce(this.search.bind(this), 300)
  }

  search() {
    const query = this.inputTarget.value.trim().toLowerCase();

    this.itemTargets.forEach((item) => {
      const text = item.textContent.toLowerCase();
      const match = text.includes(query);
      item.hidden = !match;
    });
  }
}
