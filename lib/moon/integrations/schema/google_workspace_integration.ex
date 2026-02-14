defmodule Moon.Integrations.Schema.GoogleWorkspaceIntegration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, UUIDv7, autogenerate: true}
  @foreign_key_type :binary_id
  schema "google_workspace_integrations" do
    field :email, :string
    field :api_key, :string
    field :active, :boolean, default: true

    belongs_to :tenant, Moon.Tenants.Tenant, foreign_key: :tenant_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(integration, attrs, scope) do
    integration
    |> cast(attrs, [:email, :api_key, :active])
    |> validate_required([:email, :api_key])
    |> put_change(:tenant_id, scope.tenant.id)
    |> unique_constraint([:tenant_id, :email])
  end
end
