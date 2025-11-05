import { Controller } from "@hotwired/stimulus"
import DiffMatchPatch from "diff-match-patch"

export default class extends Controller {
  static targets = ["original", "output"]
  connect() {
    this.textarea = document.getElementById('markdown');
    this.textarea.addEventListener("input", () => this.diff())
    this.diff();
  }

  diff() {
    const normalize = str => str.replace(/\r\n/g, '\n').replace(/\r/g, '\n');

    const original = normalize(JSON.parse(this.originalTarget.textContent));
    const current = normalize(this.textarea.value);

    const dmp = new DiffMatchPatch()
    const diffs = dmp.diff_main(original, current);
    dmp.diff_cleanupSemantic(diffs);

    this.outputTarget.innerHTML = '';

    let lastAddedDiv = null;
    let skipNext = false;

    diffs.forEach (([op, text]) => {
      const lines = text.split(/(?<=\n)/);
      
      lines.forEach ((line, i, arr) => {
        console.log(JSON.stringify(op));
        console.log(JSON.stringify(line));

        if ((skipNext && (op === 0 || op === -1) && line === '\n') || line === "") {
          if (line != "") skipNext = false;
          return;
        }

        const div = document.createElement('div');
        div.className = 'diff-line';

        let isNextLine = i + 1 < arr.length

        if (op === 0) {
          if (line === '\n') {
            div.classList.add('blank-line');
          } else {
            div.textContent = line;
            skipNext = false;
          }
        }

        if (op === -1) {
          if (line === '\n') {
            div.classList.add('blank-line');
          } else {
            div.textContent = line;
          }
          div.classList.add('removed');
        }
        
        if (op === 1) {
          div.classList.add('added');

          if (lastAddedDiv) {
            if (line === '\n') {
              lastAddedDiv.classList.add('blank-line');
              if (isNextLine) {
                const next_div = document.createElement('div');
                next_div.className = 'diff-line';
                next_div.classList.add('added');
                next_div.classList.add('blank-line');
                this.outputTarget.appendChild(next_div);

                lastAddedDiv = next_div;
                return;
              }
            } else if (line.length > 0 && line.endsWith('\n')) {
              lastAddedDiv.textContent = line;
              lastAddedDiv.classList.remove('blank-line');
              if (isNextLine) {
                const next_div = document.createElement('div');
                next_div.className = 'diff-line';
                next_div.classList.add('added');
                next_div.classList.add('blank-line');
                this.outputTarget.appendChild(next_div);

                lastAddedDiv = next_div;
                return;
              }
            } else if (!(line.includes('\n'))) {
              lastAddedDiv.textContent = line;
              lastAddedDiv.classList.remove('blank-line');
            }
          } else {
            if (line === '\n') {
              div.classList.add('blank-line');
              if (isNextLine) {
                const next_div = document.createElement('div');
                next_div.className = 'diff-line';
                next_div.classList.add('added');
                next_div.classList.add('blank-line');
                this.outputTarget.appendChild(div);
                this.outputTarget.appendChild(next_div);

                lastAddedDiv = next_div;
                return;
              }
            } else if (line.length > 0 && line.endsWith('\n')) {
              div.textContent = line;
              if (isNextLine) {
                const next_div = document.createElement('div');
                next_div.className = 'diff-line';
                next_div.classList.add('added');
                next_div.classList.add('blank-line');

                lastAddedDiv = next_div;

                this.outputTarget.appendChild(div);
                this.outputTarget.appendChild(next_div);

                return;
              }
            } else if (!(line.includes('\n'))) {
              div.textContent = line;
            }
          }
          skipNext = true;
        } else {
          lastAddedDiv = null;
        }
        this.outputTarget.appendChild(div);
      });
    });
  }
}
