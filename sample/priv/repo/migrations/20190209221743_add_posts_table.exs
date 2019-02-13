defmodule Sample.Repo.Migrations.AddPostsTable do
  use Ecto.Migration

  def change do

    create table(:posts) do
      add :author, :string
      add :content, :string
      timestamps()
    end

  end
end
