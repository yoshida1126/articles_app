document.addEventListener("turbo:load", logout_confirmation);
document.addEventListener("turbo:render", logout_confirmation);

function logout_confirmation () {
  let logout = document.getElementById('logout');
  if (!logout) return;

  logout.removeEventListener('click', logoutClickHandler);
  logout.addEventListener('click', logoutClickHandler);
}

function logoutClickHandler(event) {
  const leave = confirm("ログアウトしますか？再度ログインが必要になります。");
  if (!leave) event.preventDefault();
}
