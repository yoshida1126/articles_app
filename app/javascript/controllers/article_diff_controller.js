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

    const original = normalize(JSON.parse(this.originalTarget.textContent))
    const current = normalize(this.textarea.value)

    const diffs = diffLines(original, current)

    this.outputTarget.innerHTML = ''

    let lastAddedDiv = null;
    let previousText = null;

    diffs.forEach(part => {
      const lines = part.value.split(/(?<=\n)/)

      lines.forEach((line, i) => {
        const div = document.createElement('div')
        div.classList.add('diff-line')

        const escapedLine = this.escapeHTML(line)

        if (part.added) {
          if (lastAddedDiv) {
            if (i === 0) {
              if (previousText + '\n' === line) {
                lastAddedDiv.textContent = escapedLine
                this.outputTarget.appendChild(lastAddedDiv)
              } else {
                lastAddedDiv.innerHTML = `- ${previousText}`
                lastAddedDiv.classList.add('removed')
                this.outputTarget.appendChild(lastAddedDiv)

                div.innerHTML = `+ ${escapedLine}`
                div.classList.add('added')
                this.outputTarget.appendChild(div)
              }
              lastAddedDiv = document.createElement('div')
              lastAddedDiv.classList.add('diff-line')
              lastAddedDiv.classList.add('added')

              if (line.includes('\n')) {
                lastAddedDiv.textContent = '+'
                this.outputTarget.appendChild(lastAddedDiv)
              }
            } else {
              lastAddedDiv.textContent = `+ ${escapedLine}`
              this.outputTarget.appendChild(lastAddedDiv)

              lastAddedDiv = document.createElement('div')
              lastAddedDiv.classList.add('diff-line')
              lastAddedDiv.classList.add('added')

              if (line.includes('\n')) {
                lastAddedDiv.textContent = '+'
                this.outputTarget.appendChild(lastAddedDiv)
              }
            }
            return
          } else {
            div.innerHTML = `+ ${escapedLine}`
            div.classList.add('added')
          }
        } else if (part.removed) {
          if (!(line.endsWith('\n'))) {
            previousText = escapedLine

            lastAddedDiv = document.createElement('div')
            lastAddedDiv.classList.add('diff-line')
            return
          } else {
            div.innerHTML = `- ${escapedLine}`
            div.classList.add('removed')
          }
        } else {
          div.innerHTML = `${escapedLine}`
        }
        this.outputTarget.appendChild(div)
      })
    })
  }
}
