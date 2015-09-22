use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :file_upload, FileUpload.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Set a higher stacktrace during test
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :file_upload, FileUpload.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "file_upload_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :file_upload, :upload_path, "test/priv/static/images/uploads"

