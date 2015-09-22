defmodule FileUpload do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    upload_path = Application.get_env(:file_upload, :upload_path)
    unless File.exists?(upload_path) do
      File.mkdir_p!(upload_path)
    end

    children = [
      # Start the endpoint when the application starts
      supervisor(FileUpload.Endpoint, []),
      # Start the Ecto repository
      worker(FileUpload.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(FileUpload.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FileUpload.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FileUpload.Endpoint.config_change(changed, removed)
    :ok
  end
end
