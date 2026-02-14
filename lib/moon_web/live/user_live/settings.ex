defmodule MoonWeb.UserLive.Settings do
  use MoonWeb, :live_view

  on_mount {MoonWeb.UserAuth, :require_sudo_mode}

  alias Moon.Accounts
  alias Moon.Integrations
  alias Moon.Integrations.Schema.GoogleWorkspaceIntegration

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="text-center">
        <.header>
          Account Settings
          <:subtitle>Manage your account email address and password settings</:subtitle>
        </.header>
      </div>

      <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
        <.input
          field={@email_form[:email]}
          type="email"
          label="Email"
          autocomplete="username"
          required
        />
        <.button variant="primary" phx-disable-with="Changing...">Change Email</.button>
      </.form>

      <div class="divider" />

      <.form
        for={@password_form}
        id="password_form"
        action={~p"/users/update-password"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_user_email"
          autocomplete="username"
          value={@current_email}
        />
        <.input
          field={@password_form[:password]}
          type="password"
          label="New password"
          autocomplete="new-password"
          required
        />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          autocomplete="new-password"
        />
        <.button variant="primary" phx-disable-with="Saving...">
          Save Password
        </.button>
      </.form>

      <div class="divider" />

      <div class="text-center">
        <.header>
          Google Workspace Integration
          <:subtitle>
            Connect your Google Workspace account to sync emails.
          </:subtitle>
        </.header>
      </div>

      <div id="integrations" phx-update="stream" class="space-y-2 mb-4">
        <div
          :for={{dom_id, integration} <- @streams.integrations}
          id={dom_id}
          class="alert alert-success"
        >
          <.icon name="hero-check-circle" class="size-5" />
          <span class="flex-1">Connected as <strong>{integration.email}</strong></span>
          <.button
            type="button"
            phx-click="disconnect_integration"
            phx-value-id={integration.id}
            data-confirm="Are you sure you want to disconnect this Google Workspace integration?"
          >
            Disconnect
          </.button>
        </div>
      </div>

      <.form
        for={@integration_form}
        id="integration_form"
        phx-change="validate_integration"
        phx-submit="save_integration"
      >
        <.input field={@integration_form[:email]} type="email" label="Google email" required />
        <.input field={@integration_form[:api_key]} type="password" label="API key" required />
        <.button variant="primary" phx-disable-with="Saving...">
          Connect
        </.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    scope = socket.assigns.current_scope
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)
    integrations = Integrations.list_google_workspace_integrations(scope)

    integration_changeset =
      Integrations.change_google_workspace_integration(
        scope,
        %GoogleWorkspaceIntegration{},
        %{}
      )

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> stream(:integrations, integrations)
      |> assign(:integration_form, to_form(integration_changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_integration", %{"google_workspace_integration" => params}, socket) do
    scope = socket.assigns.current_scope

    integration_form =
      scope
      |> Integrations.change_google_workspace_integration(%GoogleWorkspaceIntegration{}, params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, integration_form: integration_form)}
  end

  def handle_event("save_integration", %{"google_workspace_integration" => params}, socket) do
    scope = socket.assigns.current_scope

    case Integrations.create_google_workspace_integration(scope, params) do
      {:ok, integration} ->
        integration_form =
          Integrations.change_google_workspace_integration(
            scope,
            %GoogleWorkspaceIntegration{},
            %{}
          )
          |> to_form()

        {:noreply,
         socket
         |> stream_insert(:integrations, integration)
         |> assign(:integration_form, integration_form)
         |> put_flash(:info, "Google Workspace integration saved.")}

      {:error, changeset} ->
        {:noreply, assign(socket, integration_form: to_form(changeset, action: :insert))}
    end
  end

  def handle_event("disconnect_integration", %{"id" => id}, socket) do
    scope = socket.assigns.current_scope

    case Integrations.delete_google_workspace_integration(scope, id) do
      {:ok, integration} ->
        {:noreply,
         socket
         |> stream_delete(:integrations, integration)
         |> put_flash(:info, "Google Workspace integration disconnected.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not disconnect integration.")}
    end
  end
end
