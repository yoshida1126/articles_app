import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    // ページ読み込み時に初期実行
    this.count()
  }

  count() {
    let length = this.element.value.length
    let countText = document.getElementById('count_text')
    let max = 3000
    let ratio = length / max

    if(length <= max) {
      countText.innerHTML = `${length} ／ ${max}文字`
    }

    countText.classList.remove("limit-length", "warning")

    if(ratio == 1) {
      countText.classList.add("limit-length")
    } else if (ratio >= 0.8) {
      countText.classList.add("warning")
    }
  }
}