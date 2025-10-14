document.addEventListener("turbo:load", tab_switcher);
document.addEventListener("turbo:render", tab_switcher);

function tab_switcher() {
  if (document.getElementsByClassName(".article-type")) {
    const tabs = document.querySelectorAll('.article-type .article-tab');
    const contents = document.querySelectorAll('#article-contents .articles');

    tabs.forEach(tab => {
      tab.addEventListener('click', () => {

        // タブの切り替え
        tabs.forEach(t => t.classList.remove('selected'));

        tab.classList.add('selected');


        // コンテンツの切り替え
        const target = tab.getAttribute('data-target');

        contents.forEach(content => {
          content.classList.remove('active');
          if (content.id === target) {
            content.classList.add('active');
          }
        });
      });
    });
  }
}
