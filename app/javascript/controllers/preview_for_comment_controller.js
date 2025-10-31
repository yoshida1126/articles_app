import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    connect() {
      this.input();
    }

    preview() {
        const editor_btn = this.element.nextElementSibling;
        const html = this.element.parentNode.parentNode.nextElementSibling.firstElementChild.nextElementSibling;
        const editor = this.element.parentNode.parentNode.nextElementSibling.firstElementChild;

        editor.classList.add("display") 
        this.element.classList.add("display")
        this.element.classList.toggle("img")
        editor_btn.classList.remove("display")
        html.classList.remove("display")
        html.classList.add("preview-width")
    }

    edit() {
        const preview_btn = this.element.previousElementSibling;
        const html = this.element.parentNode.parentNode.nextElementSibling.firstElementChild.nextElementSibling;
        const editor = this.element.parentNode.parentNode.nextElementSibling.firstElementChild;

        editor.classList.remove("display")
        preview_btn.classList.remove("display")
        preview_btn.classList.toggle("img")
        this.element.classList.add("display")
        html.classList.add("display")
        html.classList.remove("preview-width")
    }

    input() {
      if (!this.element.value || this.element.value === '') {
        return;
      }

      const markdown = this.element.value;

      marked.setOptions({ 
        breaks: true,
        gfm: true,
        tables: true,
        sanitize: true,
        smartLists: true,
        smartypants: false,
      }); 
      const html = marked.parse(markdown);
      const placeholder = this.element.parentNode.nextElementSibling.firstElementChild
      const content = this.element.parentNode.nextElementSibling.lastElementChild

      if (markdown.length == 0) {
          placeholder.style.display = "block";
          content.innerHTML = "";
        } else {
          placeholder.style.display = "none";

          content.innerHTML = html;
        }   
    }
}