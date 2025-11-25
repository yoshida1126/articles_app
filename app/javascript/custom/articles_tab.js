document.addEventListener("turbo:load", tabSwitcher);
document.addEventListener("turbo:render", tabSwitcher);

function tabSwitcher() {
  const tabs = document.querySelectorAll(".tab");
  const contents = document.querySelectorAll("#tab-contents .contents");

  if (!tabs.length || !contents.length) return;

  const currentPath = window.location.pathname;

  const activeTab = getActiveTabFromPath(currentPath);

  tabs.forEach(tab => {
    const targetTab = tab.dataset.pathSuffix?.replace("/", "") || "published";
    tab.classList.toggle("selected", targetTab === activeTab);

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

function getActiveTabFromPath(path) {
  if (path.endsWith("/drafts")) return "drafts";
  if (path.endsWith("/private_articles")) return "private_articles";
  if (path.endsWith("/favorite_article_lists")) return "favorite_article_lists";
  return "published";
}
