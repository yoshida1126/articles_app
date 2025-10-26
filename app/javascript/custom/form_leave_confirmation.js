document.addEventListener('turbo:load', () => {

  const submitBtns = document.getElementsByClassName('article-submit-btn');
  if (submitBtns.length === 0) return;

  if (window._formDirtyListenerInitialized) return;

  let isFormDirty = false;

  document.addEventListener('input', (e) => {
    if (e.target.matches('input, textarea, select')) {
      isFormDirty = true;
    }
  });

  document.addEventListener('click', (e) => {
    if (e.target.closest('.toggle-button')) {
      isFormDirty = true;
    }
  });

  document.addEventListener("turbo:before-visit", (event) => {
  if (isFormDirty) {
    const leave = confirm("このページを離れますか？変更内容は保存されません。");
    if (!leave) {
      event.preventDefault();
    } else {
      isFormDirty = false;
    }
  }
});

  document.addEventListener('turbo:submit-end', (event) => {
    const { success } = event.detail;
  
    if (success) {
      isFormDirty = false;
    }
  });

  window.addEventListener('beforeunload', (e) => {
    if (isFormDirty) {
      e.preventDefault();
      e.returnValue = '';
    }
  });

  window._formDirtyListenerInitialized = true;
});
