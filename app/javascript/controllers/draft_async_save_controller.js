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
    this.lastSaveDateField = document.querySelector('#last-save-date')
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

    this.lastSaveDateField.innerText = 'オートセーブ中...'

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

        if (data.updated_at !== undefined) {
          this.fadeOutIn(this.lastSaveDateField, `最終保存: ${data.updated_at}`)
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

  fadeOutIn(element, newText) {
    element.style.transition = `opacity ${2000 / 2}ms ease-in-out`
    element.style.opacity = '0'

    setTimeout(() => {
        element.innerText = newText
        element.style.opacity = '1'
    }, 2000 / 2)
  }
}