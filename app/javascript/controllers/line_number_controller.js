import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    this.lineCount()
  }

  lineCount() {
    const text = this.element.value;

    const lines = text.split('\n');

    const outputDiv = document.getElementById('mirror');

    outputDiv.innerHTML = '';

    lines.forEach(line => {
      const newDiv = document.createElement('div');

      newDiv.style.display = 'none';

      newDiv.textContent = line;

      outputDiv.appendChild(newDiv);
    });
  }
}