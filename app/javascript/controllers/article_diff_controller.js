import { Controller } from "@hotwired/stimulus"
import { diffLines } from "diff"

export default class extends Controller {
  static targets = ["original", "output"]

  connect() {
    if (document.getElementById('diff-view')) {
      this.textarea = document.getElementById("markdown")
      this.textarea.addEventListener("input", () => this.diff())
      this.diff()
    }
  }

  escapeHTML(str) {
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }

  diff() {
    const normalize = str => str.replace(/\r\n/g, '\n').replace(/\r/g, '\n')

    const original = normalize(JSON.parse(this.originalTarget.textContent) + '\n')
    const current = normalize(this.textarea.value + '\n')

    const diffs = diffLines(original, current)

    this.outputTarget.innerHTML = ''

    diffs.forEach(part => {
      const lines = part.value.split(/(?<=\n)/)

      lines.forEach(line => {
        const div = document.createElement('div')
        div.classList.add('diff-line')

        const escapedLine = this.escapeHTML(line)

        if (part.added) {
          div.innerHTML = `+ ${escapedLine}`
          div.classList.add('added')
        } else if (part.removed) {
          div.innerHTML = `- ${escapedLine}`
          div.classList.add('removed')
        } else {
          div.innerHTML = `${escapedLine}`
        }
        this.outputTarget.appendChild(div)
      })
    })
  }
}
