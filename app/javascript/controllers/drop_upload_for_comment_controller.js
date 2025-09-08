import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static values = { url: String };
  connect() {
  }

  dropUpload(e){
    e.preventDefault();
    Array.from(e.dataTransfer.files).forEach(file => this.uploadFile(file));
  }

  uploadFile(file){

    if (!this.isValidFileType(file)) {
      alert("アップロード可能な画像形式はJPEG, PNG, GIFです。ファイル形式をご確認ください。");
      return;
    }

    if (!this.isValidFileSize(file)) {
      alert("1MB以下の画像をアップロードしてください。");
      return;
    }

    fetch("/upload_comment_images_tracker", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      credentials: "same-origin", 
      body: JSON.stringify({
        byte_size: file.size
      })
    })
    .then(response => {
      if (!response.ok) {
        return response.json().then(error => {
          throw new Error(error.alert || "アップロードに失敗しました。");
        });
      }
      return response.json();
    })
    .then(data => {
      const Elements = document.querySelectorAll(".comment-upload-remaining");
      if (Elements && data.remaining_mb !== undefined) {
        Elements.forEach(element => {
          element.innerText = `本日のコメント画像の残りアップロード容量：${data.remaining_mb} MB`;
        });
      }

      const upload = new DirectUpload(file, this.urlValue);
      upload.create((error, blob) => {
        if (error) {
          console.log(error);
        } else {
          const text = this.markdownUrl(blob);
          const start = this.element.selectionStart;
          const end = this.element.selectionEnd;
          this.element.setRangeText(text,start,end)
        }
      });
    })
    .catch(error => {
      alert(error.message);
    });
  }

  markdownUrl(blob){
    const filename = blob.filename
    //const url = `https://articles-app-bucket.s3.ap-northeast-1.amazonaws.com/${blob.key}`;
    const url = `/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`;
    const prefix = (this.isImage(blob.content_type) ? '!' : '');
    const signedIdsField = this.element.parentNode.nextElementSibling;
    let signedIds = signedIdsField.value ? JSON.parse(signedIdsField.value) : [];
    signedIds.push(blob.signed_id);
    signedIdsField.value = JSON.stringify(signedIds)

    return `${prefix}[${filename}](${url})\n`;
  }

  isImage(contentType){
    return ["image/jpeg", "image/gif", "image/png"].includes(contentType);
  }

  isValidFileType(file) {
    return this.isImage(file.type);
  }

  isValidFileSize(file) {
    const maxSize = 1 * 1024 * 1024;
    return file.size <= maxSize;
  }
}
