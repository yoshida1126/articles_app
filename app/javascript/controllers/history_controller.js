import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    versions: Array
  }
  connect() {
    this.currentIndex = this.versionsValue.length - 1
    this.contentField = document.querySelector('#markdown')
    this.undoBtn = document.querySelector('#undo-change-btn')
    this.redoBtn = document.querySelector('#redo-change-btn')

    this.updateHistoryNavigationButtons()
  }

  initialize() {
    this.updateHistoryNavigationButtons = this.updateHistoryNavigationButtons.bind(this)
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
    }

    this.updateHistoryNavigationButtons()
  }

  addVersion(event) {
    const newVersion = event.detail.version

    this.versionsValue = [...this.versionsValue, newVersion]

    this.currentIndex = this.versionsValue.length - 1

    this.updateHistoryNavigationButtons()
  }

  updateHistoryNavigationButtons() {
    if (this.currentIndex >= 1) {
      this.undoBtn.style.color = '#fff'
      this.undoBtn.style.cursor = 'pointer'
      this.undoBtn.classList.add('bg-undo')
    } else {
      this.undoBtn.style.color = '#d6d6d6'
      this.undoBtn.style.cursor = 'default'
      this.undoBtn.classList.remove('bg-undo')
    }
    
    if (this.currentIndex < this.versionsValue.length - 1) {
      this.redoBtn.style.color = '#fff'
      this.redoBtn.style.cursor = 'pointer'
      this.redoBtn.classList.add('bg-redo')
    } else {
      this.redoBtn.style.color = '#d6d6d6'
      this.redoBtn.style.cursor = 'default'
      this.redoBtn.classList.remove('bg-redo')
    }
  }
}