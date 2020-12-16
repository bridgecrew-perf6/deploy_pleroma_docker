# Pleroma instance configuration

# NOTE: This file should not be committed to a repo or otherwise made public
# without removing sensitive information.

import Config

config :pleroma, Pleroma.Web.Endpoint,
   url: [host: "DOMAIN", scheme: "https", port: 443],
   secret_key_base: "SameAsInFile prod.secret.exs",
   signing_salt: "SameAsInFile prod.secret.exs"

config :pleroma, :instance,
  name: "InstanceNameOfPleroma",
  email: "YourEmailAddress",
  notify_email: "YourEmailAddress",
  limit: 5000,
  registrations_open: true,
  dynamic_configuration: true

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

config :pleroma, :database, rum_enabled: false
config :pleroma, :instance, static_dir: "instance/static/"
config :pleroma, Pleroma.Uploaders.Local, uploads: "uploads"

# Enable Strict-Transport-Security once SSL is working:
# config :pleroma, :http_security,
#   sts: true

# Configure S3 support if desired.
# The public S3 endpoint is different depending on region and provider,
# consult your S3 provider's documentation for details on what to use.
#
# config :pleroma, Pleroma.Uploaders.S3,
#   bucket: "some-bucket",
#   public_endpoint: "https://s3.amazonaws.com"
#
# Configure S3 credentials:
# config :ex_aws, :s3,
#   access_key_id: "xxxxxxxxxxxxx",
#   secret_access_key: "yyyyyyyyyyyy",
#   region: "us-east-1",
#   scheme: "https://"
#
# For using third-party S3 clones like wasabi, also do:
# config :ex_aws, :s3,
#   host: "s3.wasabisys.com"


# Configure Openstack Swift support if desired.
#
# Many openstack deployments are different, so config is left very open with
# no assumptions made on which provider you're using. This should allow very
# wide support without needing separate handlers for OVH, Rackspace, etc.
#
# config :pleroma, Pleroma.Uploaders.Swift,
#  container: "some-container",
#  username: "api-username-yyyy",
#  password: "api-key-xxxx",
#  tenant_id: "<openstack-project/tenant-id>",
#  auth_url: "https://keystone-endpoint.provider.com",
#  storage_url: "https://swift-endpoint.prodider.com/v1/AUTH_<tenant>/<container>",
#  object_url: "https://cdn-endpoint.provider.com/<container>"
#
