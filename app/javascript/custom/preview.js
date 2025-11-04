document.addEventListener("turbo:load", markdown);
document.addEventListener("turbo:render", markdown);

function markdown() {
  if(document.getElementById("preview-btn")) {
    document.removeEventListener("turbo:load", markdown)
    if (document.getElementById("markdown")) {
      const markdown_textarea = document.getElementById('markdown');
 
      function updatePreview() {
        // ユーザーが入力したMarkdownの内容を取得
        const markdown = document.getElementById('markdown').value;

        const preview = document.getElementById('html');
        const placeholder = preview.querySelector(".preview-placeholder");
        const content = preview.querySelector(".preview-content");
        
        //MarkdownをHTMLに変換する前にオプションを追加
        marked.setOptions({ 
          breaks: true,
          gfm: true,
          tables: true,
          sanitize: true,
          smartLists: true,
          smartypants: false,
        }); 

        // 取得したMarkdownをHTMLに変換。
        const html = marked.parse(markdown);
        
        if (markdown.length == 0) {
          placeholder.style.display = "block";
          content.innerHTML = "";
        } else {
          placeholder.style.display = "none";

          // idが「html」の要素に変換したHTMLを表示。
          content.innerHTML = html;
        }
      };

      // 入力があるたびにプレビューを更新
      markdown_textarea.addEventListener('input', updatePreview);

      // ページ読み込み時にも1回実行
      updatePreview();

      const preview_btn = document.getElementById("preview-btn");
      const editor_btn = document.getElementById("editor-btn");
      const html = document.getElementById("html");
      const editor = document.getElementById("editor-container")
 
      preview_btn.addEventListener("click", function() {
        if(window.matchMedia('(max-width: 767px)').matches) {
          editor.classList.toggle("display") 
          preview_btn.classList.toggle("display")
          preview_btn.classList.toggle("img")
          editor_btn.classList.toggle("display")
          html.classList.toggle("display")
          html.classList.toggle("preview-width")
          toggle_diff_btn();
        } else if (window.matchMedia('(min-width:768px)').matches) {
          preview_btn.classList.toggle("display")
          preview_btn.classList.toggle("img")
          editor_btn.classList.toggle("display")
          html.classList.toggle("display")
          editor.classList.toggle("editor-width")
          toggle_diff_btn();
        }
      });

      editor_btn.addEventListener("click", function() {
        if(window.matchMedia('(max-width: 767px)').matches) {
          if (document.querySelector(".editor-width") !== null) {
            editor.classList.toggle("editor-width")
            preview_btn.classList.toggle("display")
            preview_btn.classList.toggle("img")
            editor_btn.classList.toggle("display")
            html.classList.toggle("display")
            toggle_diff_btn();
          }
          else {
            editor.classList.toggle("display") 
            preview_btn.classList.toggle("display")
            preview_btn.classList.toggle("img")
            editor_btn.classList.toggle("display")
            html.classList.toggle("display")
            html.classList.toggle("preview-width")
            toggle_diff_btn();
          }
        } else if (window.matchMedia('(min-width:768px)').matches) {
            if (document.querySelector(".preview-width") !== null) {
              html.classList.toggle("preview-width")
              editor.classList.toggle("display")
              preview_btn.classList.toggle("display")
              editor_btn.classList.toggle("display")
              html.classList.toggle("display")
              toggle_diff_btn();
            }
            else {
              preview_btn.classList.toggle("display")
              editor_btn.classList.toggle("display")
              html.classList.toggle("display")
              editor.classList.toggle("editor-width")
              toggle_diff_btn();
            }
        }
      });
    }

    function toggle_diff_btn() {
      if (document.getElementById("diff-btn")) {
        let diff_btn = document.getElementById("diff-btn")
        diff_btn.classList.toggle("display")
        diff_btn.classList.toggle("img")
      }
    }
  }
}
