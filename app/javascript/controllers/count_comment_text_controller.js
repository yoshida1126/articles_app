import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  count() {
    let length = this.element.value.length
    let countText = document.getElementById('count_comment_text')
    if(length == 1500) {
      countText.classList.add("limit-length")
    }
    if(length < 1500) {
      if(document.getElementsByClassName("limit-length")) {
        countText.classList.remove("limit-length")
      }
      countText.innerHTML = `${length} ／ 1500文字`
    }
  }
}