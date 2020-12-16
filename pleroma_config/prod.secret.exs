# Pleroma instance configuration

# NOTE: This file should not be committed to a repo or otherwise made public
# without removing sensitive information.

import Config

config :pleroma, Pleroma.Web.Endpoint,
   url: [host: "DOMAIN", scheme: "https", port: 443],
   secret_key_base: "<use 'openssl rand -base64 48' to generate a key>",
   signing_salt: "<use 'openssl rand -base64 48 | cut -c1-8' to generate a salt>"

config :pleroma, :instance,
  name: "InstanceNameOfPleroma",
  email: "YourEmailAddress",
  notify_email: "YourEmailAddress",
  limit: 5000,
  registrations_open: false,
  dynamic_configuration: true,
  federating: true,
  federation_reachability_timeout_days: 7

config :pleroma, :media_proxy,
  enabled: false,
  redirect_on_failure: true
  #base_url: "https://cache.pleroma.social"

config :pleroma, Pleroma.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "YourPGUsername",
  password: "YourPGPassword",
  database: "pleroma",
  hostname: "192.168.5.100",
  pool_size: 10

# Configure web push notifications
config :web_push_encryption, :vapid_details,
  subject: "mailto:YourEmailAddress",
  public_key: "YourWebPushPubKey",
  private_key: "YourWebPushPrivKey"

config :pleroma, configurable_from_database: true
config :pleroma, :database, rum_enabled: false
config :pleroma, :instance, static_dir: "instance/static/"
config :pleroma, Pleroma.Uploaders.Local, uploads: "uploads"
config :pleroma, :chat, enabled: false

# Emoji
config :pleroma, :emoji,
  shortcode_globs: ["/emoji/custom/**/*.png"],
  pack_extensions: [".png", ".gif"],
  groups: [
    # Put groups that have higher priority than defaults here. Example in `docs/config/custom_emoji.md`
    Custom: ["/emoji/*.png", "/emoji/**/*.png", "/emoji/*.gif", "/emoji/**/*.gif", "/emoji/*.svg", "/emoji/**/*.svg"]
  ],
  default_manifest: "https://git.pleroma.social/pleroma/emoji-index/raw/master/index.json"

# Enable Strict-Transport-Security once SSL is working:
config :pleroma, :http_security,
  enabled: true,
  sts: true

config :pleroma, :frontend_configurations,
  pleroma_fe: %{
    logo: "/static/logo.png",
    redirectRootNoLogin: "/static/terms-of-service.html",
    redirectRootLogin: "/main/friends",
    showInstanceSpecificPanel: true,
    hidePostStats: false,
    hideUserStats: false,
    scopeCopy: true
  },
  masto_fe: %{
    showInstanceSpecificPanel: true
  }

config :pleroma, :activitypub,
  unfollow_blocked: true,
  outgoing_blocks: true,
  follow_handshake_timeout: 500,
  sign_object_fetches: true

config :pleroma, :user, deny_follow_blocked: true

config :logger,
  backends: [:console, {ExSyslogger, :ex_syslogger}]

config :logger, :ex_syslogger,
  level: :debug,
  option: [:pid, :ndelay]
