document.addEventListener("turbo:load", markdown);
document.addEventListener("turbo:render", markdown);

function markdown() {
  if(document.getElementById("preview-btn")) {
    document.removeEventListener("turbo:load", markdown)
    if (document.getElementById("markdown")) {
      const markdown_textarea = document.getElementById('markdown');
      // idが「markdown」の要素を取得。ユーザーが入力を行ったときに以下の関数が実行される。    
      markdown_textarea.addEventListener('input', function () {
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

  /*
  if (document.getElementsByClassName(".html2")) {
    const previews = document.querySelectorAll(".preview-btn")
    for(var i = 0; i < previews.length; i++) {
      previews[i].addEventListener("click", function() {
        const edita2 = this.nextElementSibling;
        const html2 = this.parentNode.parentNode.nextElementSibling.firstElementChild.nextElementSibling;
        const markdown2 = this.parentNode.parentNode.nextElementSibling.firstElementChild;

        if(window.matchMedia('(max-width: 767px)').matches) {
          markdown2.classList.add("display") 
          this.classList.add("display")
          this.classList.toggle("img")
          edita2.classList.remove("display")
          html2.classList.remove("display")
          html2.classList.add("preview-width")
        } else if (window.matchMedia('(min-width:768px)').matches) {
            this.classList.add("display")
            this.classList.toggle("img")
            edita2.classList.remove("display")
            html2.classList.remove("display")
            markdown2.classList.add("edita-width")
        }
        const markdown_textarea = markdown2  
        markdown_textarea.addEventListener('input', function () {
          marked.setOptions({ 
            breaks: true,
            gfm: true,
            tables: true,
            sanitize: true,
            smartLists: true,
            smartypants: false,
          }); 
          const html = marked.parse(markdown2.value);
          html2.innerHTML = html;
        });
      })
    }

    const editas = document.querySelectorAll(".edita")
    for(var i = 0; i < previews.length; i++) {
      editas[i].addEventListener("click", function() {
        const preview2 = this.previousElementSibling;
        const html2 = this.parentNode.parentNode.nextElementSibling.firstElementChild.nextElementSibling;
        const markdown2 = this.parentNode.parentNode.nextElementSibling.firstElementChild;

        if(window.matchMedia('(max-width: 767px)').matches) {
          if (document.querySelector(".edita-width") !== null) {
            markdown2.classList.remove("edita-width")
            preview2.classList.remove("display")
            preview2.classList.toggle("img")
            this.classList.add("display")
            html2.classList.add("display")
          }
          else {
            markdown2.classList.remove("display") 
            preview2.classList.remove("display")
            preview2.classList.toggle("img")
            this.classList.add("display")
            html2.classList.add("display")
            html2.classList.remove("preview-width")
          }
        } else if (window.matchMedia('(min-width:768px)').matches) {
            if (document.querySelector(".preview-width") !== null) {
              html2.classList.remove("preview-width")
              markdown2.classList.remove("display")
              preview2.classList.remove("display")
              this.classList.add("display")
              html2.classList.add("display")
            }
            else {
              preview2.classList.remove("display")
              this.classList.add("display")
              html2.classList.add("display")
              markdown2.classList.remove("edita-width")
            }
        }
      });
    }
  } */
