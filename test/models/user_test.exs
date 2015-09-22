defmodule FileUpload.UserTest do
  use FileUpload.ModelCase

  alias FileUpload.User
  alias FileUpload.Repo

  def fake_upload do
    %Plug.Upload{filename: "test", path: Path.expand("./test/fixtures/test.jpg")}
  end

  setup do
    upload_path = Application.get_env(:file_upload, :upload_path)
    unless File.exists?(upload_path) do
      File.mkdir_p!(upload_path)
    end

    on_exit fn ->
      File.rm_rf Path.expand "../priv/", __DIR__
    end
    :ok
  end

  test "uploads file on insert" do
    params = %{avatar_upload: fake_upload()}
    %{avatar: avatar} = Repo.insert! User.changeset(%User{}, params)

    assert avatar
    assert avatar.filename == params.avatar_upload.filename
    assert File.exists? Path.expand("../.." <> avatar.filepath, __DIR__)
  end

  test "uploads file on update" do
    user = Repo.insert! %User{}
    params = %{avatar_upload: fake_upload()}
    %{avatar: avatar} = Repo.update! User.changeset(user, params)

    assert avatar
    assert avatar.filename == params.avatar_upload.filename
    assert File.exists? Path.expand(".." <> user.avatar.filepath, __DIR__)
  end

  test "removes old file on update" do
    params = %{avatar_upload: fake_upload()}
    user = User.changeset(%User{}, params)
           |> Repo.insert!
           |> Map.put(:avatar_upload, nil)
    Repo.update!(User.changeset(user, params))

    refute File.exists? Path.expand(".." <> user.avatar.filepath, __DIR__)
  end
end
