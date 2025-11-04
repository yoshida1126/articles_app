document.addEventListener("turbo:load", diff_view);
document.addEventListener("turbo:render", diff_view);

function diff_view() {
  if(document.getElementById("diff-btn")) {
    const diff_view = document.getElementById("diff-view");
    const diff_btn = document.getElementById("diff-btn");
    const preview_btn = document.getElementById("preview-btn");
    const editor_btn = document.getElementById("editor-btn2");
    const editor = document.getElementById("editor-container");
 
    diff_btn.addEventListener("click", function() {
      if(window.matchMedia('(max-width: 767px)').matches) {
        diff_view.classList.toggle("diff-view-width")
        diff_view.classList.toggle("display")
        editor.classList.toggle("display") 
        preview_btn.classList.toggle("display")
        preview_btn.classList.toggle("img")
        editor_btn.classList.toggle("display")
        diff_btn.classList.toggle("display")
        diff_btn.classList.toggle("img")
      } else if (window.matchMedia('(min-width:768px)').matches) {
        diff_view.classList.toggle("display")
        preview_btn.classList.toggle("display")
        preview_btn.classList.toggle("img")
        editor_btn.classList.toggle("display")
        diff_btn.classList.toggle("display")
        diff_btn.classList.toggle("img")
        editor.classList.toggle("editor-width")
      }
    });

    editor_btn.addEventListener("click", function() {
      if(window.matchMedia('(max-width: 767px)').matches) {
        if (document.querySelector(".editor-width") !== null) {
          diff_view.classList.toggle("display")
          editor.classList.toggle("editor-width")
          preview_btn.classList.toggle("display")
          preview_btn.classList.toggle("img")
          editor_btn.classList.toggle("display")
          diff_btn.classList.toggle("display")
          diff_btn.classList.toggle("img")
        } else {
          diff_view.classList.toggle("diff-view-width")
          diff_view.classList.toggle("display")
          editor.classList.toggle("display") 
          preview_btn.classList.toggle("display")
          preview_btn.classList.toggle("img")
          editor_btn.classList.toggle("display")
          diff_btn.classList.toggle("display")
          diff_btn.classList.toggle("img")
        }
      } else if (window.matchMedia('(min-width:768px)').matches) {
        if (document.querySelector(".diff-view-width") !== null) {
          diff_view.classList.toggle("diff-view-width")
          diff_view.classList.toggle("display")
          editor.classList.toggle("display")
          preview_btn.classList.toggle("display")
          editor_btn.classList.toggle("display")
          diff_btn.classList.toggle("display")
          diff_btn.classList.toggle("img")
        } else {
          diff_view.classList.toggle("display")
          preview_btn.classList.toggle("display")
          editor_btn.classList.toggle("display")
          diff_btn.classList.toggle("display")
          diff_btn.classList.toggle("img")
          editor.classList.toggle("editor-width")
        }
      }
    });
  }
}
