document.addEventListener("turbo:load", listSwitcher);
document.addEventListener("turbo:render", listSwitcher);

function listSwitcher() {
  const select = document.querySelector("#share-list-select");
  if (!select) return;

  select.addEventListener("change", () => {
    const value = select.value;
    const params = new URLSearchParams(window.location.search);

    params.set("type", value);

    window.location.search = params.toString();
  });
}