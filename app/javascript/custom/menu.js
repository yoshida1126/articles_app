document.addEventListener("turbo:load", menu);
document.addEventListener("turbo:render", menu);

function menu() {
  if(document.getElementById('dropdown-menu')){
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
          if(document.getElementById('dropdown-menu')){
            let menu = document.querySelector("#dropdown-menu");
            menu.classList.remove("active");
          }
        }
      });
    }
  }

  if(document.getElementById('dropdown-menu3')){
    let account2 = document.querySelector("#account2");
    if (account2) {
        account2.addEventListener("click", function(event) {
            event.preventDefault();
            let menu = document.querySelector("#dropdown-menu3");
            menu.classList.toggle("active");
            event.stopPropagation();
        });
    }

    let active = document.getElementsByClassName("active");

    if(active) {
      $('html').click(function(e) {
        if(!$(e.target).closest('.responsive-header').length) {
          if(document.getElementById('dropdown-menu3')){
            let menu = document.querySelector("#dropdown-menu3");
            menu.classList.remove("active");
          }
        }
      });
    }
  }

  if(document.getElementById('dropdown-menu2')){
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

      let active = document.getElementsByClassName("active");

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
  }
};