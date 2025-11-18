import { Controller } from "@hotwired/stimulus"
import { updateSizeBar } from "../services/file_size_bar"

export default class extends Controller {
  static values = { csrfToken: String, userId: Number, draftId: Number }
  connect() {
    this.timeout = null
    this.saving = false
    this.retryNeeded = false

    this.changedFields = new Set()

    this.titleField = document.querySelector('#title')
    this.headerImgField = document.querySelector('#header')
    this.tagListField = document.querySelector('#tag-list')
    this.contentField = document.querySelector('#markdown')
    this.blobField = document.querySelector('#blob')
    this.draftIdField = document.querySelector('#draft-id')
  }

  initialize() {
    this.asyncSave = this.asyncSave.bind(this)
    this.processInput = this.processInput.bind(this)
  }

  processInput(event) {
    this.changedFields.add(event.target.id)

    if (this.timeout) clearTimeout(this.timeout)
    this.timeout = setTimeout( () => {
      this.asyncSave()
    }, 1000)
  }

  asyncSave () {
    if (this.saving) {
      this.retryNeeded = true
      return
    }
    this.saving = true

    const formData = this.buildFormDataFromChangedFields()

    fetch(`/users/${this.userIdValue}/article_drafts/autosave_draft`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": this.csrfTokenValue
      },
      credentials: "same-origin", 
      body: formData
    })
    .then(res => res.json())
    .then(data => {
      if (data.status === 'ok') {
        this.element.dataset.draftAsyncSaveDraftIdValue = data.id
        this.draftIdValue = data.id
        this.draftIdField.value = data.id

        if (data.remaining_mb !== undefined && data.max_size !== undefined) {
          const quotaDisplay = document.getElementById("file-size-text")
          const ratioDisplay = document.getElementById("file-size-bar")
                    
          updateSizeBar(quotaDisplay, ratioDisplay, data.remaining_mb, data.max_size)
        }

        this.changedFields.clear()
      } else {
        this.retryNeeded = true
      }
    })
    .finally(() => {
      this.saving = false

      if (this.retryNeeded) {
        this.retryNeeded = false
        asyncSave()
      }
    })
  }

  buildFormDataFromChangedFields() {
    const formData = new FormData()
    formData.append("id", this.draftIdValue || "")

    this.changedFields.forEach(fieldId => {
      if (fieldId === "title") {
        formData.append("article_draft[title]", this.titleField.value)
      }
      if (fieldId === "header") {
        const file = this.headerImgField.files[0]
        if (file) formData.append("article_draft[image]", file)
      }
      if (fieldId === "tag-list") {
        formData.append("article_draft[tag_list]", this.tagListField.value)
      }
      if (fieldId === "markdown") {
        formData.append("article_draft[content]", this.contentField.value)
        formData.append("article_draft[blob_signed_ids]", this.blobField.value)
      }
    })
    return formData
  }
}