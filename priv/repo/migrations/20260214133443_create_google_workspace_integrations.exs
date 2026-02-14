defmodule Moon.Repo.Migrations.CreateGoogleWorkspaceIntegrations do
  use Ecto.Migration

  def change do
    create table(:google_workspace_integrations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tenant_id, references(:tenants, on_delete: :delete_all, type: :binary_id), null: false
      add :email, :string, null: false
      add :api_key, :string, null: false
      add :active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:google_workspace_integrations, [:tenant_id, :email])
  end
end
