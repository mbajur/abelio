import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  static values = {delay: {type: Number, default: 300}}

  connect() {
    this.timeoutId = null
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  submit() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }

    this.timeoutId = setTimeout(() => {
      if (typeof this.element.requestSubmit === "function") {
        this.element.requestSubmit()
      } else {
        this.element.submit()
      }
    }, this.delayValue)
  }
}
