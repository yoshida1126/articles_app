# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin_all_from 'app/javascript/custom', under: 'custom'
pin 'jquery', to: 'https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js'
pin '@rails/activestorage', to: 'https://ga.jspm.io/npm:@rails/activestorage@7.1.3-4/app/assets/javascripts/activestorage.esm.js'
pin 'trix'
pin '@rails/actiontext', to: 'actiontext.js'
pin 'cropperjs', to: 'cropperjs.js' # @1.6.2
pin 'vue', to: 'vue--dist--vue.esm-browser.js.js' # @3.4.31]
pin 'bootstrap', to: 'bootstrap.min.js', preload: true
