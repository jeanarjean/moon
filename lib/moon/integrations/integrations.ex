defmodule Moon.Integrations do
  @moduledoc """
  The Integrations context.
  """

  import Ecto.Query, warn: false
  alias Moon.Repo

  alias Moon.Integrations.Schema.GoogleWorkspaceIntegration
  alias Moon.Accounts.Scope

  @doc """
  Lists all Google Workspace integrations for the given scope's tenant.
  """
  def list_google_workspace_integrations(%Scope{} = scope) do
    GoogleWorkspaceIntegration
    |> where(tenant_id: ^scope.tenant.id)
    |> Repo.all()
  end

  @doc """
  Gets a single Google Workspace integration by id, scoped to the tenant.
  """
  def get_google_workspace_integration(%Scope{} = scope, id) do
    GoogleWorkspaceIntegration
    |> where(tenant_id: ^scope.tenant.id)
    |> Repo.get(id)
  end

  @doc """
  Creates a Google Workspace integration for the given scope's tenant.
  """
  def create_google_workspace_integration(%Scope{} = scope, attrs) do
    %GoogleWorkspaceIntegration{}
    |> GoogleWorkspaceIntegration.changeset(attrs, scope)
    |> Repo.insert()
  end

  @doc """
  Deletes a Google Workspace integration by id, scoped to the tenant.
  """
  def delete_google_workspace_integration(%Scope{} = scope, id) do
    case get_google_workspace_integration(scope, id) do
      nil -> {:error, :not_found}
      integration -> Repo.delete(integration)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking integration changes.
  """
  def change_google_workspace_integration(%Scope{} = scope, %GoogleWorkspaceIntegration{} = integration, attrs \\ %{}) do
    GoogleWorkspaceIntegration.changeset(integration, attrs, scope)
  end
end
