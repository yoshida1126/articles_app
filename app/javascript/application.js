// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
const application = Application.start();
eagerLoadControllersFrom("controllers", application);
Turbo.session.drive = true
import "custom/menu" 
import "custom/preview"
import "custom/profile_image_trimming"
import "custom/marked"
import "custom/article_header_image_preview" 
import "custom/search_window"
import "custom/articles_list_tab"
import "custom/time_range_switcher"
import "custom/articles_tab"
import "custom/form_leave_confirmation"
import jquery from "jquery" 
window.$ = jquery 
import "trix"
import "@rails/actiontext"

document.addEventListener("turbo:load", flash);
document.addEventListener("turbo:submit-end", flash);

function flash() {
  document.removeEventListener("turbo:load", flash);
  setTimeout("$('.flash-alert').fadeOut('slow')", 3000);
};