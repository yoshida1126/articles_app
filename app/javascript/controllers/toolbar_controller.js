import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    preview() {
        const edita = this.element.nextElementSibling;
        const html = this.element.parentNode.parentNode.nextElementSibling.firstElementChild.nextElementSibling;
        const markdown = this.element.parentNode.parentNode.nextElementSibling.firstElementChild;

        if(window.matchMedia('(max-width: 767px)').matches) {
            markdown.classList.add("display") 
            this.element.classList.add("display")
            this.element.classList.toggle("img")
            edita.classList.remove("display")
            html.classList.remove("display")
            html.classList.add("preview-width")
          } else if (window.matchMedia('(min-width:768px)').matches) {
              this.element.classList.add("display")
              this.element.classList.toggle("img")
              edita.classList.remove("display")
              html.classList.remove("display")
              markdown.classList.add("edita-width")
          }
    }

    edit() {
        const preview = this.element.previousElementSibling;
        const html = this.element.parentNode.parentNode.nextElementSibling.firstElementChild.nextElementSibling;
        const markdown = this.element.parentNode.parentNode.nextElementSibling.firstElementChild;

        if(window.matchMedia('(max-width: 767px)').matches) {
          if (this.element.parentNode.parentNode.nextElementSibling.firstElementChild.classList.contains("edita-width") == true) {
            markdown.classList.remove("edita-width")
            preview.classList.remove("display")
            preview.classList.toggle("img")
            this.element.classList.add("display")
            html.classList.add("display")
          }
          else {
            markdown.classList.remove("display") 
            preview.classList.remove("display")
            preview.classList.toggle("img")
            this.element.classList.add("display")
            html.classList.add("display")
            html.classList.remove("preview-width")
          }
        } else if (window.matchMedia('(min-width:768px)').matches) {
            if (this.element.parentNode.parentNode.nextElementSibling.firstElementChild.nextElementSibling.classList.contains("preview-width") == true) {
              html.classList.remove("preview-width")
              markdown.classList.remove("display")
              preview.classList.remove("display")
              this.element.classList.add("display")
              html.classList.add("display")
            }
            else {
              preview.classList.remove("display")
              this.element.classList.add("display")
              html.classList.add("display")
              markdown.classList.remove("edita-width")
            }
        }
    }

    input() {
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
      this.element.nextElementSibling.innerHTML = html;
    }
}