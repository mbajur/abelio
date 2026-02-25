import {Controller} from "@hotwired/stimulus"
import {FetchRequest} from "@rails/request.js"

export default class extends Controller {
  static targets = ["form", "input", "progress"]
  static values = {finalUrl: String}

  openFilePicker(event) {
    if (event) {
      const ignore = event.target.closest("input, button, label, a, textarea, select")
      if (ignore) return
    }

    if (this.hasInputTarget) {
      this.inputTarget.click()
    }
  }

  async upload() {
    const input = this.inputTarget
    const files = Array.from(input.files || [])
    if (files.length === 0) return

    const baseData = this.buildBaseFormData()
    const total = files.length

    for (let index = 0; index < total; index += 1) {
      this.updateProgress(`Uploading ${index + 1} / ${total}`)

      const data = new FormData()
      for (const [key, value] of baseData.entries()) {
        data.append(key, value)
      }
      data.append(this.fileParamName(input.name), files[index])

      await this.submitFormData(data)
    }

    this.updateProgress("All uploads complete")
    if (this.hasFinalUrlValue && this.finalUrlValue) {
      await this.submitFinalRequest()
    }

    input.value = ""
  }

  buildBaseFormData() {
    const data = new FormData()
    const elements = Array.from(this.formTarget.elements)

    elements.forEach((el) => {
      if (!el.name) return
      if (el.type === "file") return
      if (el.type === "submit") return

      if (el.type === "checkbox" || el.type === "radio") {
        if (!el.checked) return
      }

      data.append(el.name, el.value)
    })

    return data
  }

  async submitFormData(data) {
    const method = (this.formTarget.getAttribute("method") || "post").toLowerCase()
    const request = new FetchRequest(method, this.formTarget.action, {
      body: data,
      responseKind: "turbo-stream",
    })
    const response = await request.perform()

    if (!response.ok) {
      this.updateProgress("Upload failed")
      throw new Error("Upload failed")
    }
  }

  async submitFinalRequest() {
    const request = new FetchRequest("post", this.finalUrlValue, {
      responseKind: "turbo-stream",
    })
    await request.perform()
  }

  fileParamName(name) {
    return name.replace(/\[\]$/, "")
  }

  updateProgress(text) {
    if (this.hasProgressTarget) {
      this.progressTarget.textContent = text
    }
  }
}
