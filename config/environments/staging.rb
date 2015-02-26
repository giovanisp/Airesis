Airesis::Application.configure do
  config.cache_classes = true

  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.i18n.fallbacks = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  config.action_mailer.perform_deliveries = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  config.assets.precompile += %w(endless_page.js paypal-button.min.js landing/main.js landing/all.js homepage.js jquery.js jquery.qtip.js ice/index.js html2canvas.js i18n/*.js proposals/show.js elfinder.full.js elFinderSupportVer1.js proposals/edit.js)
  config.assets.precompile += %w(back_enabled.png landing.css landing/all.css redmond/custom.css menu_left.css jquery.qtip.css foundation_and_overrides.css ckeditor/* elfinder.min.css)

  # Generate digests for assets URLs
  config.assets.digest = true

  config.assets.version = '1.0'

  config.force_ssl = false

  config.logger = Logger.new(Rails.root.join("log", Rails.env + ".log"), 50, 100.megabytes)
end

Airesis::Application.default_url_options = Airesis::Application.config.action_mailer.default_url_options
