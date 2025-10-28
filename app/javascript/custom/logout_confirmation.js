document.addEventListener("turbo:load", logout_confirmation);
document.addEventListener("turbo:render", logout_confirmation);

function logout_confirmation () {
  let logout = document.getElementById('logout');
  let logout_mobile = document.getElementById('logout-mobile')
  if (!logout && !logout_mobile) return;

  [logout, logout_mobile].forEach((el) => {
    if (!el) return;

    el.removeEventListener('click', logoutClickHandler);
    el.addEventListener('click', logoutClickHandler);
  });
}

function logoutClickHandler(event) {
  const leave = confirm("ログアウトしますか？\n再度ログインが必要になります。");
  if (!leave) event.preventDefault();
}
