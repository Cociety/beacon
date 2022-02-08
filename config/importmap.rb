# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "beacon/api", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.js", preload: true
pin "@hotwired/stimulus-importmap-autoloader", to: "stimulus-importmap-autoloader.js"
pin "@rails/activestorage", to: "@rails--activestorage.js" # @7.0.1
pin "@rails/ujs", to: "@rails--ujs.js" # @7.0.1
pin_all_from "app/javascript/controllers", under: "controllers"
pin "mobile-drag-drop" # @2.3.0
pin "mobile-drag-drop/scroll-behaviour", to: "mobile-drag-drop--scroll-behaviour.js" # @2.3.0
