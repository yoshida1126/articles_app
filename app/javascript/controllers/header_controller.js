import { Controller } from "@hotwired/stimulus"
import { updateSizeBar } from "../services/file_size_bar"

export default class extends Controller {
  static values = {
    remaining: Number,
    max: Number
  }
  static targets = ["quota", "bar"]

  connect() {
    updateSizeBar(
      this.quotaTarget,
      this.barTarget,
      this.remainingValue,
      this.maxValue
    )

    this.mediaQuery = window.matchMedia("(max-width: 640px)")
    this._mqCallback = () => {
      updateSizeBar(
        this.quotaTarget,
        this.barTarget,
        this.remainingValue,
        this.maxValue
      )
    }

    this.mediaQuery.addEventListener("change", this._mqCallback)
  }

  disconnect() {
    this.mediaQuery?.removeEventListener("change", this._mqCallback)
  }
}