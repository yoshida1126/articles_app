// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
//import "@hotwired/turbo-rails"
import { Turbo } from "@hotwired/turbo-rails" 
Turbo.session.drive = true
import "controllers"
import "custom/menu" 
import "custom/preview"
import "custom/image"
import "custom/image_upload"
import "custom/profile_image_trimming"
import "custom/marked"
import "custom/article_header_image_preview" 
import "custom/search_window"
import jquery from "jquery" 
window.$ = jquery 
import "trix"
import "@rails/actiontext"
