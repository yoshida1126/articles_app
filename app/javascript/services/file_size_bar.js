export function updateSizeBar(quotaDisplay, ratioDisplay, remaining, max) {

  if(window.matchMedia('(max-width: 640px)').matches) {
    quotaDisplay.innerText = `${remaining}MB / ${max}MB`
  } else if (window.matchMedia('(min-width: 640px)').matches) {
    quotaDisplay.innerText = `残りファイルサイズ ${remaining}MB / ${max}MB`
  }

  const ratio = (remaining / max) * 100;

  ratioDisplay.style.width = `${ratio}%`;

  if (ratio <= 10) {
    ratioDisplay.style.background =
      'linear-gradient(to right, #c45d5d, #a94444)';
  } else if (ratio <= 30) {
    ratioDisplay.style.background =
      'linear-gradient(to right, #d8a55b, #c98c3d)';
  } else {
    ratioDisplay.style.background =
      'linear-gradient(to right, #5a8f99, #7fb3bd)';
  }

  if (remaining < 1) {
    const headerSelect = document.getElementById('header-select')
    const message = '※ヘッダー画像は明日以降アップロードできます。'

    const hasMessage = headerSelect.nextSibling.textContent === message

    if (!hasMessage){
      headerSelect.style.display = 'none'
      headerSelect.after(message)
    }
  }
}
