document.addEventListener("turbo:load", markdown);
document.addEventListener("turbo:render", markdown);

function markdown() {
  if(document.getElementById("preview-btn")) {
    document.removeEventListener("turbo:load", markdown)
    if (document.getElementById("markdown_for_comment")) {
      const markdown_textarea = document.getElementById('markdown_for_comment');
      // idが「markdown」の要素を取得。ユーザーが入力を行ったときに以下の関数が実行される。    
      markdown_textarea.addEventListener('input', function () {
        // ユーザーが入力したMarkdownの内容を取得。
        const markdown = document.getElementById('markdown_for_comment').value;
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
        // idが「html」の要素に変換したHTMLを表示。
        document.getElementById('html').innerHTML = html;
      });

      const preview = document.getElementById("preview-btn");
      const edita = document.getElementById("edita");
      const html = document.getElementById("html");
      const markdown = document.getElementById("markdown_for_comment")
 
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