document.addEventListener("turbo:load", header_image_preview);
document.addEventListener("turbo:render", header_image_preview);

function header_image_preview () {
  const preview = document.getElementById("header-img-preview");

  if (!preview) return null; 

  const fileField = document.querySelector('input[type="file"][name="article_draft[image]"]');

  fileField.addEventListener('change', function(e) {
    const oldPreview = document.querySelector('.preview');
    if (oldPreview) {
        oldPreview.remove();
    };

    const file = e.target.files[0];
    const placeholder = document.getElementById("header-image-placeholder");

    if (file.size > 1 * 1024 * 1024) {
      alert("1MB以下の画像をアップロードしてください。");
      e.target.value = '';
      placeholder.style.display = "block";
      return;
    }

    if (placeholder) {
        placeholder.style.display = "none";
    } 

    const blob = window.URL.createObjectURL(file) 

    const previewWrapper = document.createElement('div');
    previewWrapper.setAttribute('class', 'preview');

    const previewImage = document.createElement('img');
    previewImage.setAttribute('src', blob);

    previewWrapper.appendChild(previewImage);
    preview.appendChild(previewWrapper);
  });
}