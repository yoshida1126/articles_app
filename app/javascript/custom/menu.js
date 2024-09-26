document.addEventListener("turbo:load", menu);
document.addEventListener("turbo:render", menu);

function menu() {
  document.removeEventListener("turbo:load", menu);
    let account = document.querySelector("#account");
    if (account) {
        account.addEventListener("click", function(event) { 
          event.preventDefault();
          let menu = document.querySelector("#dropdown-menu");
          menu.classList.toggle("active");
          event.stopPropagation();
        });
    }

    let active = document.getElementsByClassName("active");

    if (active) {
      $('html').click(function(e) {
        if(!$(e.target).closest('.dropdown-menu').length) {
          let menu = document.querySelector("#dropdown-menu");
          menu.classList.remove("active");
        }
      });
    }

    let account2 = document.querySelector("#account2");
    if (account2) {
        account2.addEventListener("click", function(event) {
            event.preventDefault();
            let menu = document.querySelector("#dropdown-menu3");
            menu.classList.toggle("active");
            event.stopPropagation();
        });
    }

    if(active) {
      $('html').click(function(e) {
        if(!$(e.target).closest('.responsive-header').length) {
          let menu = document.querySelector("#dropdown-menu3");
          menu.classList.remove("active");
        }
      });
    }

    if (document.querySelector("#dropdown-menu2")) {
      let option = document.querySelector("#option");
      if (option) {
          option.addEventListener("click", function(event) {
            event.preventDefault();
            let menu = document.querySelector("#dropdown-menu2");
            menu.classList.toggle("active");
            event.stopPropagation();
          });
      }

      if(active) {
        let option = document.querySelector(".article-option");
        if(option) {
          $('html').click(function(e) {
            if(!$(e.target).closest('.article-option').length) {
              let menu = document.querySelector("#dropdown-menu2");
              if (menu) {
                menu.classList.remove("active");
              }
            }
          }); 
        } else {
            return null;
        }
      }
    }

    if (document.querySelector(".dropdown3")) {
      var options = document.querySelectorAll(".dropdown3") 
      for(var i = 0; i < options.length; i++) {
        options[i].addEventListener("click", function(event) {
          event.preventDefault();
          var menu = this.nextElementSibling;
          var edit_btn = menu.firstElementChild
          edit_btn.addEventListener("click", function(event) {
            event.preventDefault();
            var comment_box = edit_btn.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode
            comment_box.style.display = "none";
            var comment_edit = comment_box.nextElementSibling 
            comment_edit.style.display = "";
          })
          menu.classList.toggle("active");
          event.stopPropagation();
        })
      }

      if (document.querySelector(".cancel-btn")) {
        var cancel_btns = document.querySelectorAll(".cancel-btn")
        for(var i = 0; i < cancel_btns.length; i++) {
          cancel_btns[i].addEventListener("click", function(event) {
            event.preventDefault();
            var comment_box = this.parentNode.parentNode.parentNode.parentNode.previousElementSibling
            comment_box.style.display = "";
            var comment_edit = this.parentNode.parentNode.parentNode.parentNode
            comment_edit.style.display ="none";
          })
        }
      }

      if(active) {
        let options = document.querySelectorAll(".article-comment-option");
        if(options) {
          $('html').click(function(e) {
            if(!$(e.target).closest('.article-comment-option').length) {
              let menus = document.querySelectorAll(".article-comment-option");
              if (menus) {
                for(var i = 0; i < menus.length; i++) {
                  menus[i].classList.remove("active");
                }
              }
            }
          }); 
        } else {
            return null;
        }
      }
    }
};