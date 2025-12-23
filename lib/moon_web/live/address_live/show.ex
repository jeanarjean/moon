defmodule MoonWeb.AddressLive.Show do
  use MoonWeb, :live_view

  alias Moon.Addresses
  alias Moon.Addresses.Schema.Address

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Address {@address.id}
        <:subtitle>This is a address record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/addresses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/addresses/#{@address}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit address
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@address.name}</:item>
        <:item title="Street Address">{@address.street_address}</:item>
        <:item title="City">{@address.city}</:item>
        <:item title="Province">{@address.province}</:item>
        <:item title="Postal Code">{@address.postal_code}</:item>
        <:item title="Country">{@address.country}</:item>
        <:item title="Lat">{@address.lat}</:item>
        <:item title="Lng">{@address.lng}</:item>
        <:item title="Address Type">{@address.address_type}</:item>
        <:item title="Notes">{@address.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Addresses.subscribe_addresses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Address")
     |> assign(:address, Addresses.get_address!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Address{id: id} = address},
        %{assigns: %{address: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :address, address)}
  end

  def handle_info(
        {:deleted, %Address{id: id}},
        %{assigns: %{address: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current address was deleted.")
     |> push_navigate(to: ~p"/addresses")}
  end

  def handle_info({type, %Address{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
