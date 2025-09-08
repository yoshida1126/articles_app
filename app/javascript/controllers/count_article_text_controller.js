import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  count() {
    let length = this.element.value.length
    let countText = document.getElementById('count_text')
    if(length == 3000) {
      countText.classList.add("limit-length")
    }
    if(length < 3000) {
      if(document.getElementsByClassName("limit-length")) {
        countText.classList.remove("limit-length")
      }
      countText.innerHTML = `${length} ／ 3000文字`
    }
  }
}