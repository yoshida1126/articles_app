// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

import MarkdownUploadController from './markdown_upload_controller'
application.register('markdown-upload', MarkdownUploadController)

import ArticleImageUploadConroller from './article_image_upload_controller' 
application.register('article-image-upload', ArticleImageUploadConroller)