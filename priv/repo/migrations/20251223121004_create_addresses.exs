defmodule Moon.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :text, null: false
      add :street_address, :text
      add :city, :text
      add :province, :text
      add :postal_code, :text
      add :country, :text, default: "Canada"
      add :lat, :decimal
      add :lng, :decimal
      add :address_type, :text
      add :notes, :text
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:addresses, [:user_id])
    create unique_index(:addresses, [:user_id, :name])
    create index(:addresses, [:user_id, :address_type])
    create index(:addresses, [:user_id, :city])
  end
end
