import { Controller } from "@hotwired/stimulus"
import DiffMatchPatch from "diff-match-patch"

export default class extends Controller {
  static values = { original: String }
  static targets = ["output"]
  connect() {
    this.textarea = document.getElementById('markdown');
    this.textarea.addEventListener("input", () => this.diff())
    this.diff()
  }

  diff() {
    const dmp = new DiffMatchPatch()
    const currentContent = document.getElementById('markdown').value
    const diffs = dmp.diff_main(
      this.originalValue.split("\n").join("\n"),
      currentContent.split("\n").join("\n")
    )
    
    const html = diffs.map(([op, text]) => {
      const safeText = text.replace(/&/g, "&amp;")
                       .replace(/</g, "&lt;")
                       .replace(/>/g, "&gt;")
                       .replace(/\n/g, "<br>")
      switch (op) {
        case -1: return `<del>${safeText}</del>`
        case 1:  return `<ins>${safeText}</ins>`
        default: return `<span>${safeText}</span>`
      }
    }).join("")

    this.outputTarget.innerHTML = html
  }
}