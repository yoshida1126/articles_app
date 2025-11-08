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

    this.mirror.addEventListener("scroll", (e) => this.synchScroll(e))
    this.preview.addEventListener("scroll", (e) => this.synchScroll(e))

    if (this.diffView) {
      this.diffView.addEventListener("scroll", (e) => this.synchScroll(e))
    }
  }

  synchScroll(event) {
    if (!this.synchTarget.checked) return
    if (this.isSyncing) return

    this.isSyncing = true

    const source = event.target

    const ratio = source.scrollTop / (source.scrollHeight - source.clientHeight)

    const targets = [this.text, this.mirror, this.preview, this.lineNumbers].filter(Boolean)

    for (const el of targets) {
      if (el === source) continue
      const newTop = ratio * (el.scrollHeight - el.clientHeight)
      el.scrollTop = newTop
    }

    if (this.diffView && source !== this.diffView) {
      const newTop = ratio * (this.diffView.scrollHeight - this.diffView.clientHeight)
      this.diffView.scrollTop = newTop
    }

    this.isSyncing = false
  }

  toggle() {
    this.synchTarget.checked = !this.synchTarget.checked

    this.scrollEvent && this.scrollEvent()

    this.synchTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
