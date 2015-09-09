defmodule FileUpload.User do
  use FileUpload.Web, :model

  schema "users" do
    field :email, :string
    field :avatar, :string
    field :avatar_upload, :any, virtual: true

    timestamps
  end

  @required_fields ~w(email)
  @optional_fields ~w(avatar_upload)
  @upload_path "/images/uploads/"
  @upload_full_path Path.join(__DIR__, "../../priv/static" <> @upload_path) |> Path.expand()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> set_avatar
  end

  def upload_path do
    @upload_path
  end

  defp set_avatar(changeset) do
    unless File.exists?(@upload_full_path) do
      File.mkdir(@upload_full_path)
    end

    if avatar_upload = changeset.params["avatar_upload"] do
      %{path: path, filename: filename} = avatar_upload
      filename = "#{changeset.model.id}-#{filename}"
      new_path = Path.join([@upload_full_path, filename])
      build_path = Application.app_dir(:file_upload, Path.join([
        "priv/static", "images/uploads", filename]))
      File.cp!(path, new_path)
      File.cp!(path, build_path)
      if avatar = changeset.model.avatar do
        [@upload_full_path, avatar]
        |> Path.join()
        |> File.rm!
      end
      put_change(changeset, :avatar, filename)
    else
      changeset
    end
  end
end
