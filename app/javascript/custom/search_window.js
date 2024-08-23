document.addEventListener("turbo:load", function() {
  const search_window_open = document.getElementById("search-window-open")
  const search_window = document.getElementById("responsive-search-window")
  const search_window_child = document.getElementById("search-window")
  const search_window_close = document.getElementById("search-window-close")

  search_window_open.addEventListener("click", function() {
    search_window.classList.toggle("display")
    search_window.classList.toggle("display-flex")
    search_window_child.classList.toggle("display")
    search_window_child.classList.toggle("display-flex")
    search_window_close.classList.toggle("display") 
  });

  search_window_close.addEventListener("click", function() {
    search_window.classList.toggle("display")
    search_window.classList.toggle("display-flex")
    search_window_child.classList.toggle("display")
    search_window_child.classList.toggle("display-flex")
    search_window_close.classList.toggle("display") 
  });

  window.addEventListener("resize", function() {
    const mdSize = 768 
    const windowWidth = document.body.clientWidth 
    if (windowWidth > mdSize) {
      if (search_window.classList.contains("display-flex")) {
        search_window.classList.remove("display-flex")
        search_window.classList.add("display")
        search_window_child.classList.remove("display-flex")
        search_window_child.classList.add("display")
        search_window_child.classList.remove("display-flex")
        search_window_close.classList.add("display") 
      }
    }
  });
});