if(document.getElementById("count_text")) {
    document.addEventListener("turbo:load", count);
    document.addEventListener("turbo:render", count); 
}

function count() {  
    let count = document.getElementsByClassName("count");
    const articleText = document.getElementById('markdown');
    articleText.addEventListener("keyup", () => {
        let length = articleText.value.length
        let countText = document.getElementById('count_text')
        if(length == 3000) {
            countText.classList.add("limit-length")
        }
        if(length < 3000) {
            if(document.getElementsByClassName("limit-length")) {
              countText.classList.remove("limit-length")
            }
            countText.innerHTML = `${length} ／3000文字`
        }
    });
}