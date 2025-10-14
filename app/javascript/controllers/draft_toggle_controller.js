import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["input"];
  static values = { article: Boolean }

  connect() {
    const isDraft = this.articleValue
    this.updateButtons(isDraft)
    this.inputTarget.value = isDraft
  }

  selectDraft(event) {
    const value = event.target.dataset.draftToggleValue === "true"
    this.inputTarget.value = value
    this.updateButtons(value)
  }

  updateButtons(activeValue) {
    const buttons = this.element.querySelectorAll('button')
    buttons.forEach((btn) => {
      const isActive = btn.dataset.draftToggleValue === String(activeValue)
      btn.classList.toggle("active", isActive)
    })
  }
}
