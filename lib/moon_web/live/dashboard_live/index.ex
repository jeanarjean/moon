defmodule MoonWeb.DashboardLive.Index do
  use MoonWeb, :live_view
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
