document.addEventListener("turbo:load", tab_switcher);
document.addEventListener("turbo:render", tab_switcher);

function tab_switcher() {
  const tabs = document.querySelectorAll(".article-tab");
  const contents = document.querySelectorAll("#article-contents .articles");

  if (!tabs.length || !contents.length) return;

  const currentPath = window.location.pathname;

  const isDraftPage = currentPath.endsWith('/drafts');

  const activeTab = isDraftPage ? "drafts" : "published";

  tabs.forEach(tab => {
    const target = tab.dataset.pathSuffix === "/drafts" ? "drafts" : "published";
    tab.classList.toggle("selected", target === activeTab);

    tab.addEventListener("click", () => {
      const userId = getUserIdFromPath(currentPath);
      if (!userId) return;

      const pathSuffix = tab.dataset.pathSuffix || "";
      window.location.href = `/users/${userId}${pathSuffix}`;
    });
  });

  contents.forEach(content => {
    content.classList.toggle("active", content.id === activeTab);
  });
}

function getUserIdFromPath(path) {
  const match = path.match(/^\/users\/(\d+)/);
  return match ? match[1] : null;
}
