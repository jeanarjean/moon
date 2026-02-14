defmodule Moon.Tenants do
  @moduledoc """
  The Tenants context.
  """

  alias Moon.Repo
  alias Moon.Tenants.Tenant

  @doc """
  Creates a tenant.
  """
  def create_tenant(attrs) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Repo.insert()
  end
end
