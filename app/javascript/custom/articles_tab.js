document.addEventListener("turbo:load", tab_switcher);
document.addEventListener("turbo:render", tab_switcher);

function tab_switcher() {
  if (document.getElementsByClassName("article-type")) {
    const tabs = document.querySelectorAll('.article-type .article-tab');
    const contents = document.querySelectorAll('#article-contents .articles');

    const params = new URLSearchParams(window.location.search);
    const initialTab = params.get('tab') || 'published';

    tabs.forEach(tab => {
      if (tab.getAttribute('data-target') === initialTab) {
        tab.classList.add('selected');
      } else {
        tab.classList.remove('selected');
      }
    });

    contents.forEach(content => {
      if (content.id === initialTab) {
        content.classList.add('active');
      } else {
        content.classList.remove('active');
      }
    });

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

        const newUrl = new URL(window.location);
        newUrl.searchParams.set('tab', target);
        window.history.pushState(null, '', newUrl.toString());
      });
    });
  }
}
