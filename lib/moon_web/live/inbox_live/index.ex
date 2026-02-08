defmodule MoonWeb.InboxLive.Index do
  use MoonWeb, :live_view

  alias Moon.Addresses

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Addresses.subscribe_addresses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Addresses")
     |> stream(:addresses, list_addresses(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    address = Addresses.get_address!(socket.assigns.current_scope, id)
    {:ok, _} = Addresses.delete_address(socket.assigns.current_scope, address)

    {:noreply, stream_delete(socket, :addresses, address)}
  end

  @impl true
  def handle_info({type, %Moon.Addresses.Schema.Address{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :addresses, list_addresses(socket.assigns.current_scope), reset: true)}
  end

  defp list_addresses(current_scope) do
    Addresses.list_addresses(current_scope)
  end
end
