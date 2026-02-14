defmodule Moon.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    alter table(:users) do
      add :tenant_id, references(:tenants, type: :binary_id, on_delete: :delete_all)
    end

    flush()

    execute(&backfill_tenants/0, fn -> :ok end)

    alter table(:users) do
      modify :tenant_id, :binary_id, null: false, from: {:binary_id, null: true}
    end

    create index(:users, [:tenant_id])
  end

  defp backfill_tenants do
    repo().query!("""
    INSERT INTO tenants (id, name, inserted_at, updated_at)
    SELECT gen_random_uuid(), email, now(), now()
    FROM users
    WHERE tenant_id IS NULL
    """)

    repo().query!("""
    UPDATE users
    SET tenant_id = tenants.id
    FROM tenants
    WHERE users.email = tenants.name
    AND users.tenant_id IS NULL
    """)
  end
end
