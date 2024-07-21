document.addEventListener("turbo:load", function() {
      // idが「markdown」の要素を取得。ユーザーが入力を行ったときに以下の関数が実行される。    
      document.getElementById('markdown').addEventListener('input', function () {
        // ユーザーが入力したMarkdownの内容を取得。
        const markdown = document.getElementById('markdown').value;
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

  const preview = document.getElementById("preview");
  const edita = document.getElementById("edita");
  const html = document.getElementById("html");
  const markdown = document.getElementById("markdown")

  preview.addEventListener("click", function() {
    preview.classList.toggle("display")
    preview.classList.toggle("img")
    edita.classList.toggle("display")
    html.classList.toggle("display")
    markdown.classList.toggle("display")
  });

  edita.addEventListener("click", function() {
    preview.classList.toggle("display")
    edita.classList.toggle("display")
    html.classList.toggle("display")
    markdown.classList.toggle("display")
  });
});

