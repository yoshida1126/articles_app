import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    versions: Array
  }
  connect() {
    this.currentIndex = this.versionsValue.length - 1
    this.contentField = document.querySelector('#markdown')
  }

  navigate_history(event) {
    const button = event.target.closest("[data-direction]")

    if (!button) return

    const step = Number(button.dataset.direction)
    const nextIndex = this.currentIndex + step

    if (nextIndex >= 0 && nextIndex < this.versionsValue.length) {
      this.currentIndex = nextIndex

      const content = this.versionsValue[this.currentIndex]
      this.contentField.value = content

      this.contentField.dispatchEvent(
        new CustomEvent("history:restore", {
          bubbles: true,
          detail: { content }
        })
      )

      this.contentField.dispatchEvent(
        new Event("input", { bubbles: true })
      )
    } else {
      console.log("これ以上進む/戻ることはできません。", nextIndex)
    }
  }

  addVersion(event) {
    const newVersion = event.detail.version

    this.versionsValue = [...this.versionsValue, newVersion]

    this.currentIndex = this.versionsValue.length - 1

    console.log(this.currentIndex)
  }
}