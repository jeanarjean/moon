defmodule Moon.Addresses.Schema.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, UUIDv7, autogenerate: true}
  @foreign_key_type :binary_id
  schema "addresses" do
    field :name, :string
    field :street_address, :string
    field :city, :string
    field :province, :string
    field :postal_code, :string
    field :country, :string, default: "Canada"
    field :lat, :decimal
    field :lng, :decimal
    field :address_type, :string
    field :notes, :string

    belongs_to :user, Moon.Accounts.User, foreign_key: :user_id, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(address, attrs, user_scope) do
    address
    |> cast(attrs, [
      :name,
      :street_address,
      :city,
      :province,
      :postal_code,
      :country,
      :lat,
      :lng,
      :address_type,
      :notes
    ])
    |> validate_required([:name])
    |> validate_inclusion(:address_type, ~w(terminal warehouse port customer other))
    |> put_change(:user_id, user_scope.user.id)
  end

  @doc """
  Returns a display-friendly string for the address.
  """
  def display_string(%__MODULE__{} = address) do
    [address.name, address.street_address, address.city]
    |> Enum.filter(&(&1 && &1 != ""))
    |> Enum.join(", ")
  end
end
