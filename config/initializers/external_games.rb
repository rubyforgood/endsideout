# Host that serves the EndsideOut games. The games are embedded in an iframe and
# call back into the game_attempts API, so this host is also the CORS allowlist.
Rails.application.config.x.external_games.host =
  if Rails.env.production?
    "endsideoutgames.netlify.app"
  else
    "staging--endsideout-games.netlify.app"
  end
