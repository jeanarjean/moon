defmodule Moon.Tenants.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Moon.Accounts.User

  @primary_key {:id, UUIDv7, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tenants" do
    field :name, :string

    has_many :users, User

    timestamps(type: :utc_datetime)
  end

  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
