import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"
import { updateSizeBar } from "../services/file_size_bar"

export default class extends Controller {
  static values = { url: String, csrfToken: String }
  connect() {
  }

  imageUpload(e){
    e.preventDefault();
    Array.from(e.target.files).forEach(file => this.uploadFile(file));
    Array.from(e.target.files).null;
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

    fetch("/upload_images_tracker", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfTokenValue
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
      const upload = new DirectUpload(file, this.urlValue);
      upload.create((error, blob) => {
        if (error) {
          console.log(error);
        } else {
          const text = this.markdownUrl(blob);
          const form = document.getElementById('markdown');

          const end = form.value.length;
          form.focus();
          form.setSelectionRange(end, end);
          form.setRangeText(text, end, end, "end");

          form.dispatchEvent(new Event('input', { bubbles: true }));

          if (data.remaining_mb !== undefined && data.max_size !== undefined) {
            const quotaDisplay = document.getElementById("file-size-text")
            const ratioDisplay = document.getElementById("file-size-bar")
            
            updateSizeBar(quotaDisplay, ratioDisplay, data.remaining_mb, data.max_size)
          }
        }
      });
    })
    .catch(error => {
      alert(error.message); // 制限超過などを通知
    });
  }

  markdownUrl(blob){
    const filename = blob.filename
    //const url = `https://articles-app-bucket.s3.ap-northeast-1.amazonaws.com/${blob.key}`;
    const url = `/rails/active_storage/blobs/${blob.signed_id}/${blob.filename}`;
    const prefix = (this.isImage(blob.content_type) ? '!' : '');
    const signedIdsField = document.getElementById("blob");
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