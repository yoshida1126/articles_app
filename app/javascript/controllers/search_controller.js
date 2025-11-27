import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["queryInput", "responsiveQueryInput"]

  connect() {}

  inputCheck(event) {
    if (this.queryInputTarget.value.trim() === "") {
      event.preventDefault()
    }
  }

  responsiveInputCheck(event) {
    if (this.responsiveQueryInputTarget.value.trim() === "") {
      event.preventDefault()
    }
  }
}