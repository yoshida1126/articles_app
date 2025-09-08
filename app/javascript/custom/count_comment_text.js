if(document.getElementById("count_comment_text")) {
    document.addEventListener("turbo:load", count);
    document.addEventListener("turbo:render", count); 
}

function count() {  
    let count = document.getElementsByClassName("count_comment");
    const commentText = document.getElementById('markdown_for_comment');
    commentText.addEventListener("keyup", () => {
        let length = commentText.value.length
        let countText = document.getElementById('count_comment_text')
        if(length == 1500) {
            countText.classList.add("limit-length")
        }
        if(length < 1500) {
            if(document.getElementsByClassName("limit-length")) {
              countText.classList.remove("limit-length")
            }
            countText.innerHTML = `${length} ／ 1500文字`
        }
    });
}