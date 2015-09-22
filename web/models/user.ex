defmodule FileUpload.User do
  use FileUpload.Web, :model

  schema "users" do
    field :email, :string
    field :avatar, :map
    field :avatar_upload, :any, virtual: true

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(email avatar_upload)
  @upload_path Application.get_env(:file_upload, :upload_path)

  before_insert :put_file
  before_update :put_file
  before_update :rm_file
  after_delete :rm_file_on_delete

  def put_file(changeset) do
    if upload = get_change(changeset, :avatar_upload) do
      %{path: tmp_path, filename: filename} = upload
      file_id  = generate_file_id()
      filepath = Path.join([@upload_path, file_id, Path.extname(filename)])
      copy_files(tmp_path, filepath)
      map = %{filename: filename, filepath: "/" <> filepath}

      put_change(changeset, :avatar, map)
    else
      changeset
    end
  end

  def rm_file(%{model: model} = changeset) do
    new_filepath = get_change(changeset, :avatar)
    old_filepath = Map.get(model, :avatar)[:filepath]

    if new_filepath && old_filepath do
      rm_files(old_filepath)
    end

    changeset
  end

  def rm_file_on_delete(%{model: model} = changeset) do
    old_filepath = Map.get(model, :avatar)[:filepath]

    if old_filepath do
      rm_files(old_filepath)
    end

    changeset
  end

  defp rm_files(old_filepath) do
    File.rm!("." <> old_filepath)
  end

  defp copy_files(tmp_path, filepath) do
    File.cp!(tmp_path, filepath)
  end

  defp generate_file_id() do
    :crypto.strong_rand_bytes(30) |> Base.encode16(case: :lower) |> binary_part(0,30)
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
