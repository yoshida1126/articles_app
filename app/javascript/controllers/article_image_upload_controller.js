import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static values = { url: String };
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

    const upload = new DirectUpload(file, this.urlValue);
    upload.create((error, blob) => {
      if (error) {
        console.log(error);
      } else {
        const text = this.markdownUrl(blob);
        const form = document.getElementById('markdown')

        const end = form.value.length;
        form.focus();
        form.setSelectionRange(end, end);
        
        form.setRangeText(text,end,end,"end")
        form.innerHTML = text;
      }
    })
  }

  markdownUrl(blob){
    const filename = blob.filename
    // const url = `https://articles-app-bucket.s3.ap-northeast-1.amazonaws.com/${blob.key}`;
    const url = `/rails/active_storage/blobs/${blob.signed_id}/${filename}`;
    const prefix = (this.isImage(blob.content_type) ? '!' : '');
    // document.getElementById('blob').value = blob.blob_sined_id

    return `${prefix}[${filename}](${url})\n`;
  }

  isImage(contentType){
    return ["image/jpeg", "image/gif", "image/png"].includes(contentType);
  }

  isValidFileType(file) {
    return this.isImage(file.type);
  }

  isValidFileSize(file) {
    const maxSize = 1 * 1024 * 1024; // 3MB in bytes
    return file.size <= maxSize;
  }
}