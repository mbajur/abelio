import {Controller} from "@hotwired/stimulus"
import {createPopper} from "@popperjs/core"

export default class extends Controller {
  static targets = ["button", "menu"]
  static values = {
    placement: {
      type: String,
      default: "bottom-start",
    }
  }

  connect() {
    this.popper = null
    this.handleClickOutside = this.handleClickOutside.bind(this)
  }

  toggle() {
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden")

    this.popper = createPopper(this.buttonTarget, this.menuTarget, {
      placement: this.placementValue,
      modifiers: [
        {
          name: "offset",
          options: {
            offset: [0, 8],
          },
        },
      ],
    })

    document.addEventListener("click", this.handleClickOutside)
  }

  close() {
    this.menuTarget.classList.add("hidden")

    if (this.popper) {
      this.popper.destroy()
      this.popper = null
    }

    document.removeEventListener("click", this.handleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    this.close()
  }
}
