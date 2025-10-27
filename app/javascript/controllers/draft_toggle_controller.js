import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.input = document.getElementById("published-input")
    this.form = document.getElementById("article-draft-form")
    this.publishOptions = document.getElementById("publish-options")
    this.mobileOptions = document.getElementById("publish-options-mobile")

    this.setInitialToggleState()

    this.updatePublishOptionsDisplay()
    this.syncVisibilityRadioWithHiddenField()

    window.addEventListener("resize", () => {
      this.updatePublishOptionsDisplay()
      this.syncVisibilityRadioWithHiddenField()
    })

    const radios = [
      ...document.querySelectorAll('input[name="visibility_pc"]'),
      ...document.querySelectorAll('input[name="visibility_mobile"]')
    ]
    radios.forEach(radio => {
      radio.addEventListener('change', () => this.handleVisibilityChange())
    })
  }

  setInitialToggleState() {
    const value = this.input?.value
    const buttons = this.element.querySelectorAll(".toggle-button")

    buttons.forEach(btn => {
      if (btn.dataset.draftToggleValue === "true") {
        btn.classList.toggle("active", value === "true" || value === "false")
      } else {
        btn.classList.toggle("active", value === "")
      }
    })

    const isPublished = value === "true" || value === "false"
    this.updatePublishOptionsDisplay(isPublished)

    const userId = document.getElementById('draft-toggle').dataset.userId;
    const draftId = document.getElementById('draft-toggle').dataset.draftId;

    if (this.form) {
      const activeToggle = this.element.querySelector('.toggle-button.active');
      const isPublished = activeToggle?.dataset.draftToggleValue === "true";

      this.form.action = isPublished
        ? `/users/${userId}/article_drafts/commit`
        : `/users/${userId}/article_drafts/save_draft`
    }
  }

  selectDraft(event) {
    const isPublished = event.currentTarget.dataset.draftToggleValue === "true"
    const userId = document.getElementById('draft-toggle').dataset.userId;

    const newAction = isPublished
      ? `/users/${userId}/article_drafts/commit`
      : `/users/${userId}/article_drafts/save_draft`

    if (this.form) {
      this.form.action = newAction
    }

    this.toggleActive(event.currentTarget)
    this.updatePublishOptionsDisplay(isPublished)

    if (isPublished) {
      if (!this.input.value) {
        this.input.value = "true"
      }
      this.syncVisibilityRadioWithHiddenField()
    } else {
      this.input.value = ""
    }
  }

  toggleActive(activeButton) {
    const buttons = this.element.querySelectorAll(".toggle-button")
    buttons.forEach(btn => btn.classList.remove("active"))
    activeButton.classList.add("active")
  }

  updatePublishOptionsDisplay() {
    const isMobile = window.innerWidth <= 768;

    const activeToggle = document.querySelector('.toggle-button.active');
    const isPublished = activeToggle?.dataset.draftToggleValue === "true";

    if (this.publishOptions) {
      this.publishOptions.style.display = isPublished && !isMobile ? "inline-flex" : "none";
    }

    if (this.mobileOptions) {
      this.mobileOptions.style.display = isPublished && isMobile ? "inline-flex" : "none";
    }

    const visibility = this.input?.value === "false" ? "private" : "public";

    const targets = document.querySelectorAll(
      `input[name="${isMobile ? 'visibility_mobile' : 'visibility_pc'}"]`
    );

    targets.forEach(radio => {
      radio.checked = radio.value === visibility;
    });
  }


  handleVisibilityChange() {
    const isMobile = window.innerWidth <= 768
    const selected = document.querySelector(
      `input[name="${isMobile ? 'visibility_mobile' : 'visibility_pc'}"]:checked`
    )

    if (selected && this.input) {
      const value = selected.value === "public" ? "true" : "false"
      this.input.value = value
    }
  }

  syncVisibilityRadioWithHiddenField() {
    const isMobile = window.innerWidth <= 768
    const visibility = this.input.value === "false" ? "private" : "public"

    const targets = document.querySelectorAll(
      `input[name="${isMobile ? 'visibility_mobile' : 'visibility_pc'}"]`
    )

    targets.forEach(radio => {
      radio.checked = radio.value === visibility
    })
  }
}
