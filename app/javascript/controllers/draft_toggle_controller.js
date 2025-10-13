import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["input"]

  connect() {
    this.updateButtons(true)
    this.inputTarget.value = true
  }

  selectDraft(event) {
    const value = event.target.dataset.draftToggleValue === "true"
    this.inputTarget.value = value
    this.updateButtons(value)
  }

  updateButtons(activeValue) {
    const buttons = this.element.querySelectorAll("button")
    buttons.forEach((btn) => {
      const isActive = btn.dataset.draftToggleValue === String(activeValue)
      btn.classList.toggle("active", isActive)
    })
  }
}