defmodule Moon.IntegrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Moon.Integrations` context.
  """

  @doc """
  Generate a Google Workspace integration.
  """
  def google_workspace_integration_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: "workspace#{System.unique_integer()}@example.com",
        api_key: "sk-test-key-#{System.unique_integer()}"
      })

    {:ok, integration} = Moon.Integrations.create_google_workspace_integration(scope, attrs)
    integration
  end
end
