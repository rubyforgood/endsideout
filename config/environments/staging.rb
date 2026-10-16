require_relative "production"

Rails.application.configure do
  staging_host = "staging-classroom.endsideout.org"

  config.action_mailer.default_url_options = { host: staging_host, protocol: "https" }
  config.hosts = [ staging_host ]
end
