import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    menu(event) {
        event.preventDefault() 
        if(this.element.nextElementSibling.classList.contains("active")) {
            this.close();
        } else {
            this.open();
        }
    }

    edit(event) {
        event.preventDefault();
        var comment_box = this.element.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
        comment_box.style.display = "none";
        var comment_edit = this.element.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.nextElementSibling;
        comment_edit.style.display = "";
        event.stopPropagation();
    }

    cancel(event) {
        event.preventDefault();
        var comment_box = this.element.parentNode.parentNode.parentNode.parentNode.previousElementSibling
        comment_box.style.display = "";
        var comment_edit = this.element.parentNode.parentNode.parentNode.parentNode
        comment_edit.style.display ="none";
        this.element.parentNode.parentNode.parentNode.parentNode.previousElementSibling.firstElementChild.lastElementChild.lastElementChild.firstElementChild.lastElementChild.classList.remove("active");
    }

    open() {
        this.element.nextElementSibling.classList.add("active");
    }

    close() {
        this.element.nextElementSibling.classList.remove("active");
    }
}
