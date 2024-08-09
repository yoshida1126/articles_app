document.addEventListener("turbo:load", function() {
  const preview = document.getElementById("header-img-preview");

  if (!preview) return null; 

  const fileField = document.querySelector('input[type="file"][name="article[image]"]');

  fileField.addEventListener('change', function(e) {
    const oldPreview = document.querySelector('.preview');
    if (oldPreview) {
        oldPreview.remove();
    };

    const p = document.querySelector("p");

    if (p) {
        p.remove();
    } 

    const file = e.target.files[0];

    const blob = window.URL.createObjectURL(file) 

    const previewWrapper = document.createElement('div');
    previewWrapper.setAttribute('class', 'preview');

    const previewImage = document.createElement('img');
    previewImage.setAttribute('src', blob);

    previewWrapper.appendChild(previewImage);
    preview.appendChild(previewWrapper);
  });
})