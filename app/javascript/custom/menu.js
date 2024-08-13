document.addEventListener("turbo:load", function() {
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

     
      if (active) {
        if(document.querySelector(".article-option")) {
          return null
        }
        $('html').click(function(e) {
          if(!$(e.target).closest('.article-option').length) {
            let menu = document.querySelector("#dropdown-menu2");
            menu.classList.remove("active");
          }
        });
      } 
    }
});
