import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { csrfToken: String, userId: Number, draftId: Number }
  connect() {
    this.timeout = null
    this.saving = false

    this.changedFields = new Set()

    this.titleField = document.querySelector('#title')
    this.headerImgField = document.querySelector('#header')
    this.tagListField = document.querySelector('#tag-list')
    this.contentField = document.querySelector('#markdown')
    this.blobField = document.querySelector('#blob')
    this.draftIdField = document.querySelector('#draft-id')
  }

  initialize() {
    this.asynchSave = this.asynchSave.bind(this)
    this.processInput = this.processInput.bind(this)
  }

  processInput(event) {
    this.changedFields.add(event.target.id)

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
      article_draft: {}
    }

    this.changedFields.forEach(fieldId => {
      if (fieldId === "title") {
        payload.article_draft.title = this.titleField.value
      }
      if (fieldId === "header") {
        const formData = new FormData()
        formData.append('image', this.headerImgField.files[0])

        payload.article_draft.image = formData
      }
      if (fieldId === "tag-list") {
        payload.article_draft.tag_list = this.tagListField.value
      }
      if (fieldId === "markdown") {
        payload.article_draft.content = this.contentField.value
        payload.article_draft.blob_signed_ids = this.blobField.value
      }
    })

    this.changedFields.clear()

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
        this.element.dataset.draftAsynchSaveDraftIdValue = data.id
        this.draftIdValue = data.id
        this.draftIdField.value = data.id
      }
    })
    .finally(() => {
      this.saving = false
    })
  }
}