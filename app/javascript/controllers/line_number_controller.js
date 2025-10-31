import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    this.lineCount()
  }

  lineCount() {
    const text = this.element.value;

    const lines = text.split('\n');

    const outputDiv = document.getElementById('mirror');
    const lineNumbers = document.getElementById('line-numbers')

    outputDiv.innerHTML = '';
    lineNumbers.innerHTML = '';

    lines.forEach((line, i) => {
      const newDiv = document.createElement('div');
      const count = document.createElement('div');

      newDiv.innerHTML = line === '' ? '&nbsp;' : line;
      outputDiv.appendChild(newDiv);

      count.textContent = i + 1;
      lineNumbers.appendChild(count);
    });

    if (this._pendingSync) cancelAnimationFrame(this._pendingSync);
    this._pendingSync = requestAnimationFrame(() => {
      Array.from(outputDiv.children).forEach((lineEl, i) => {
        const countEl = lineNumbers.children[i];
        countEl.style.height = `${lineEl.offsetHeight}px`;
      });

      this.scrollSynch();
      this._pendingSync = null;
    });
  }

  scrollSynch() {
    const mirror = document.getElementById('mirror');
    const lineNumbers = document.getElementById('line-numbers')

    mirror.scrollTop = this.element.scrollTop
    lineNumbers.scrollTop = this.element.scrollTop;
  }
}