import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { csrfToken: String, userId: Number, draftId: Number }
  connect() {
    this.timeout = null
    this.saving = false
    this.titleField = document.querySelector('#title')
    this.tagListField = document.querySelector('#tag-list')
    this.contentField = document.querySelector('#markdown')
    this.hiddenField = document.querySelector('#draft-id-field')

    if (this.hiddenField.value) {
      this.draftIdValue = parseInt(this.hiddenField.value)
    }
  }

  initialize() {
    this.asynchSave = this.asynchSave.bind(this)
    this.processInput = this.processInput.bind(this)
  }

  processInput() {
    if (this.timeout) clearTimeout(this.timeout)

    this.timeout = setTimeout( () => {
      this.asynchSave()
    }, 1000)
  }

  asynchSave () {
    if (this.saving) return
    this.saving = true

    const payload = {
      id: this.draftIdValue || null,
      article_draft: {
        title: this.titleField.value,
        tag_list: this.tagListField.value,
        content: this.contentField.value
      }
    }

    fetch(`/users/${this.userIdValue}/article_drafts/autosave_draft`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfTokenValue
      },
      credentials: "same-origin", 
      body: JSON.stringify(payload)
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === 'ok') {
        this.draftIdValue = data.id
        this.element.dataset.draftAsynchSaveDraftIdValue = data.id
        this.hiddenField.value = data.id
      }
    })
    .finally(() => {
      this.saving = false
    })
  }
}