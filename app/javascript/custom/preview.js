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

      const preview = document.getElementById("preview-btn");
      const edita = document.getElementById("edita");
      const html = document.getElementById("html");
      const markdown = document.getElementById("markdown")
 
      preview.addEventListener("click", function() {
        if(window.matchMedia('(max-width: 767px)').matches) {
          markdown.classList.toggle("display") 
          preview.classList.toggle("display")
          preview.classList.toggle("img")
          edita.classList.toggle("display")
          html.classList.toggle("display")
          html.classList.toggle("preview-width")
        } else if (window.matchMedia('(min-width:768px)').matches) {
            preview.classList.toggle("display")
            preview.classList.toggle("img")
            edita.classList.toggle("display")
            html.classList.toggle("display")
            markdown.classList.toggle("edita-width")
        }
      });

      edita.addEventListener("click", function() {
        if(window.matchMedia('(max-width: 767px)').matches) {
          if (document.querySelector(".edita-width") !== null) {
            markdown.classList.toggle("edita-width")
            preview.classList.toggle("display")
            preview.classList.toggle("img")
            edita.classList.toggle("display")
            html.classList.toggle("display")
          }
          else {
            markdown.classList.toggle("display") 
            preview.classList.toggle("display")
            preview.classList.toggle("img")
            edita.classList.toggle("display")
            html.classList.toggle("display")
            html.classList.toggle("preview-width")
          }
        } else if (window.matchMedia('(min-width:768px)').matches) {
            if (document.querySelector(".preview-width") !== null) {
              html.classList.toggle("preview-width")
              markdown.classList.toggle("display")
              preview.classList.toggle("display")
              edita.classList.toggle("display")
              html.classList.toggle("display")
            }
            else {
              preview.classList.toggle("display")
              edita.classList.toggle("display")
              html.classList.toggle("display")
              markdown.classList.toggle("edita-width")
            }
        }
      });
    }
  }
}
