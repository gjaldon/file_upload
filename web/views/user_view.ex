defmodule FileUpload.UserView do
  use FileUpload.Web, :view

  alias FileUpload.User

  def avatar_src(conn, %User{avatar: avatar}) do
    static_path(conn, "/" <> Path.relative_to(avatar["filepath"], "/priv/static"))
  end
end
