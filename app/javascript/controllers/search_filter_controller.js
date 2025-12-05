import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["creationDate", "searchField", "dateField"]

  connect() {}

  modalOpen() {
    const filterModal = document.getElementById('filter-modal')
    filterModal.style.display = "block"

    const overlay = document.createElement('div')
    overlay.classList.add('overlay')
    overlay.addEventListener("click", this.modalClose)
    document.body.appendChild(overlay)
  }

  modalClose(e) {
    document.body.querySelectorAll('input[type="radio"]').forEach(input => input.checked = false)

    const node = document.getElementsByClassName('creation-date')[0]
    node.querySelectorAll('input').forEach(input => input.disabled = true)
    const defaultRadio = node.querySelector('input[value=""]')
    if (defaultRadio) {
      defaultRadio.checked = true
    }

    const dateField = document.getElementById("q_created_at_filter")
    dateField.value = ""

    const filterModal = document.getElementById('filter-modal')
    filterModal.style.display = "none"

    document.body.removeChild(e.target)
  }

  modalCloseWithBtn() {
    document.body.querySelectorAll('input[type="radio"]').forEach(input => input.checked = false)

    const node = document.getElementsByClassName('creation-date')[0]
    node.querySelectorAll('input').forEach(input => input.disabled = true)
    const defaultRadio = node.querySelector('input[value=""]')
    if (defaultRadio) {
      defaultRadio.checked = true
    }

    const dateField = document.getElementById("q_created_at_filter")
    dateField.value = ""

    const filterModal = document.getElementById('filter-modal')
    filterModal.style.display = "none"
    
    const overlay = document.querySelector('.overlay')
    if (overlay) {
      overlay.remove()
    }
  }

  toggleDate(event) {
    const target = event.target.value;
    const enabled = target === "article" || target === "list"
    this.creationDateTarget.querySelectorAll('input').forEach(input => {
      input.disabled = !enabled
    })
  }

  updateSearchParam(event) {
    const target = event.target.value
    let paramName

    switch (target) {
      case "article":
        paramName = "title_or_content_cont"
        break
      case "list":
        paramName = "list_title_cont"
        break
      case "user":
        paramName = "name_cont"
        break
      default:
        paramName = "title_or_content_cont"
    }
    this.searchFieldTarget.name = `q[${paramName}]`
  }

  updateDateFilter(event) {
    const value = event.target.value
    this.dateFieldTarget.value = value
  }
}