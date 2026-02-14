defmodule Moon.IntegrationsTest do
  use Moon.DataCase

  alias Moon.Integrations
  alias Moon.Integrations.Schema.GoogleWorkspaceIntegration

  import Moon.AccountsFixtures, only: [user_scope_fixture: 0]
  import Moon.IntegrationsFixtures

  @valid_attrs %{email: "workspace@example.com", api_key: "sk-test-key-123"}
  @invalid_attrs %{email: nil, api_key: nil}

  describe "list_google_workspace_integrations/1" do
    test "returns all integrations for the tenant" do
      scope = user_scope_fixture()
      integration = google_workspace_integration_fixture(scope)

      assert Integrations.list_google_workspace_integrations(scope) == [integration]
    end

    test "does not return integrations from other tenants" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      integration = google_workspace_integration_fixture(scope)
      other_integration = google_workspace_integration_fixture(other_scope)

      assert Integrations.list_google_workspace_integrations(scope) == [integration]
      assert Integrations.list_google_workspace_integrations(other_scope) == [other_integration]
    end

    test "returns multiple integrations for the same tenant" do
      scope = user_scope_fixture()
      i1 = google_workspace_integration_fixture(scope, %{email: "one@example.com"})
      i2 = google_workspace_integration_fixture(scope, %{email: "two@example.com"})

      result = Integrations.list_google_workspace_integrations(scope)
      assert length(result) == 2
      assert MapSet.new(Enum.map(result, & &1.id)) == MapSet.new([i1.id, i2.id])
    end
  end

  describe "get_google_workspace_integration/2" do
    test "returns the integration scoped to the tenant" do
      scope = user_scope_fixture()
      integration = google_workspace_integration_fixture(scope)

      assert Integrations.get_google_workspace_integration(scope, integration.id) == integration
    end

    test "returns nil for an integration from another tenant" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      integration = google_workspace_integration_fixture(scope)

      assert Integrations.get_google_workspace_integration(other_scope, integration.id) == nil
    end

    test "returns nil for a non-existent id" do
      scope = user_scope_fixture()
      assert Integrations.get_google_workspace_integration(scope, Ecto.UUID.generate()) == nil
    end
  end

  describe "create_google_workspace_integration/2" do
    test "with valid data creates an integration" do
      scope = user_scope_fixture()

      assert {:ok, %GoogleWorkspaceIntegration{} = integration} =
               Integrations.create_google_workspace_integration(scope, @valid_attrs)

      assert integration.email == "workspace@example.com"
      assert integration.api_key == "sk-test-key-123"
      assert integration.active == true
      assert integration.tenant_id == scope.tenant.id
    end

    test "with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Integrations.create_google_workspace_integration(scope, @invalid_attrs)
    end

    test "enforces unique email per tenant" do
      scope = user_scope_fixture()
      google_workspace_integration_fixture(scope, %{email: "dupe@example.com"})

      assert {:error, changeset} =
               Integrations.create_google_workspace_integration(scope, %{
                 email: "dupe@example.com",
                 api_key: "another-key"
               })

      assert errors_on(changeset).tenant_id != nil
    end

    test "allows same email on different tenants" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()

      assert {:ok, _} = Integrations.create_google_workspace_integration(scope, @valid_attrs)

      assert {:ok, _} =
               Integrations.create_google_workspace_integration(other_scope, @valid_attrs)
    end
  end

  describe "delete_google_workspace_integration/2" do
    test "deletes the integration" do
      scope = user_scope_fixture()
      integration = google_workspace_integration_fixture(scope)

      assert {:ok, %GoogleWorkspaceIntegration{}} =
               Integrations.delete_google_workspace_integration(scope, integration.id)

      assert Integrations.get_google_workspace_integration(scope, integration.id) == nil
    end

    test "returns error when integration belongs to another tenant" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      integration = google_workspace_integration_fixture(scope)

      assert {:error, :not_found} =
               Integrations.delete_google_workspace_integration(other_scope, integration.id)
    end

    test "returns error for non-existent id" do
      scope = user_scope_fixture()

      assert {:error, :not_found} =
               Integrations.delete_google_workspace_integration(scope, Ecto.UUID.generate())
    end
  end

  describe "change_google_workspace_integration/3" do
    test "returns a changeset" do
      scope = user_scope_fixture()

      assert %Ecto.Changeset{} =
               Integrations.change_google_workspace_integration(
                 scope,
                 %GoogleWorkspaceIntegration{}
               )
    end
  end
end
