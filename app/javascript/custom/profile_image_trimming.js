import Cropper from "cropperjs";

document.addEventListener("turbo:load", function() {
  if (document.getElementById("profile_image_upload")) {
    let target = document.getElementById('target');
    var cropperImg = document.getElementById('cropper-img');
    var origin_Url = cropperImg.src;
    var close_btn = document.getElementsByClassName("close")[0];
    var modal = document.getElementById("modal-for-trim");
    var overlay = document.createElement("div");
    var selected_img_trim = document.getElementById("selected-img-trim");
    overlay.classList.add("overlay")
    var cropper = new Cropper(cropperImg, {
      viewMode: 3,
      aspectRatio: 1,
      restore: false,
      center: false,
      highlight: false,
      cropBoxResizable: false,
      guides: false,
      minContainerWidth: 300,
      minContainerHeight: 300,
      minCropBoxHeight: 300,
      minCropBoxWidth: 300,
    });
  
    document.getElementById('crop-btn').addEventListener('click', function() {
      document.body.removeChild(overlay);
      $('body').css('overflow-y', 'auto');
      modal.style.display = "none";
      var resultImgUrl = cropper.getCroppedCanvas().toDataURL();
      target.setAttribute("src",resultImgUrl);
      origin_Url = resultImgUrl; // 元画像のURLをトリミング後の画像ファイルのURLに変える
      var uploador = document.getElementById("profile_image_upload")
      var croppedCanvas = cropper.getCroppedCanvas();

      // 送信する画像ファイルをトリミングした画像ファイルに挿し替える
      croppedCanvas.toBlob(function(imgBlob) {
        var croppedImgFile = new File([imgBlob], 'profile_img.jpg', {type: "image/jpg"});
        var dt = new DataTransfer();
        dt.items.add(croppedImgFile);
        document.getElementById("profile_image_upload").files = dt.files;
      });
    });

    document.querySelector('input[type="file"]').addEventListener('change', function(e) {
      if(e.target.files[0]) {
        var file = e.target.files[0]; 
        var file_url = URL.createObjectURL(file)

        cropper.replace(file_url);

        var fileReader = new FileReader(file);

        fileReader.readAsDataURL(file);

        fileReader.addEventListener('load', (e) => {
          cropperImg.setAttribute("src",e.target.result);
          var blob = new Blob([file], { type: 'image/jpg' });
          var url = URL.createObjectURL(blob);
        });

        document.body.appendChild(overlay);
        modal.style.display = "block";
        $('body').css('overflow-y', 'hidden');
      };
    });

    // トリミング画面をモーダルに表示する
    selected_img_trim.onclick = function() {
      document.body.appendChild(overlay);
      modal.style.display = "block";
      $('body').css('overflow-y', 'hidden');
    };

    // トリミングをキャンセルした時の動作(バツボタンをクリックした時)
    close_btn.onclick = function() {
      document.body.removeChild(overlay);
      modal.style.display = "none";
      $('body').css('overflow-y', 'auto');
      // inputタグをリセットする
      document.getElementById("profile_image_upload").value = '';
      // トリミングする画像を元の画像に戻す(処理を中断しないと元の画像が一瞬表示されるためsetTimeoutを使っている)
      setTimeout(function() { cropper.replace(origin_Url) }, 300);
    };

    // トリミングをキャンセルした時の動作(モーダル画面の外側をクリックした時)
    $('.modal').click(function() {
      $(this).fadeOut();
      document.body.removeChild(overlay);
      $('body').css('overflow-y', 'auto');
      // inputタグをリセットする
      document.getElementById("profile_image_upload").value = '';
      // トリミングする画像を元の画像に戻す(処理を中断しないと元の画像が一瞬表示されるためsetTimeoutを使っている)
      ajsetTimeout(function() { cropper.replace(origin_Url) }, 300);
    });

    $('.modal-dialog').on('click', function(e) {
      e.stopPropagation();
    });
  };
});