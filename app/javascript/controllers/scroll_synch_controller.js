import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["synch"]

  connect() {
    this.synchScroll = this.synchScroll.bind(this)
    this.isSyncing = false

    this.text = document.getElementById("markdown")
    this.mirror = document.getElementById("mirror")
    this.preview = document.getElementById("html")
    this.lineNumbers = document.getElementById("line-numbers")
    this.diffView = document.getElementById("diff")

    this.text.addEventListener("scroll", (e) => this.synchScroll(e))
  }

  synchScroll(event) {
    if (!this.synchTarget.checked) return
    if (this.isSyncing) return

    this.isSyncing = true

    const source = event.target

    this.alignScrollPositions(source)

    this.isSyncing = false
  }

  toggle() {
    this.synchTarget.checked = !this.synchTarget.checked

    this.synchTarget.dispatchEvent(new Event("change", { bubbles: true }))

    if (this.synchTarget.checked) {
      this.alignScrollPositions(this.text)
    }
  }

  alignScrollPositions(source) {
    const ratio = source.scrollTop / (source.scrollHeight - source.clientHeight)
    const clampedRatio = Math.min(Math.max(ratio, 0), 1)

    const targets = [this.mirror, this.preview, this.diffView, this.lineNumbers].filter(Boolean)
    for (const el of targets) {
      if (el.scrollHeight <= el.clientHeight) continue
      const newTop = clampedRatio * (el.scrollHeight - el.clientHeight)
      el.scrollTop = newTop
    }
  }
}
