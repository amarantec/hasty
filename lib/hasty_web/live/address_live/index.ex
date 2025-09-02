defmodule HastyWeb.AddressLive.Index do
  use HastyWeb, :live_view

  alias Hasty.Addresses

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Addresses
        <:actions>
          <.button navigate={~p"/users/settings"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/addresses/new"}>
            <.icon name="hero-plus" /> New Address
          </.button>
        </:actions>
      </.header>

      <.table
        id="addresses"
        rows={@streams.addresses}
        row_click={fn {_id, address} -> JS.navigate(~p"/addresses/#{address}") end}
      >
        <:col :let={{_id, address}} label="Street">{address.street}</:col>
        <:col :let={{_id, address}} label="Number">{address.number}</:col>
        <:col :let={{_id, address}} label="City">{address.city}</:col>
        <:col :let={{_id, address}} label="Neighborhood">{address.neighborhood}</:col>
        <:col :let={{_id, address}} label="State">{address.state}</:col>
        <:col :let={{_id, address}} label="Country">{address.country}</:col>
        <:col :let={{_id, address}} label="ZIP Code">{address.zip_code}</:col>
        <:action :let={{_id, address}}>
          <div class="sr-only">
            <.link navigate={~p"/addresses/#{address}"}>Show</.link>
          </div>
          <.link navigate={~p"/addresses/#{address}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, address}}>
          <.link
            phx-click={JS.push("delete", value: %{id: address.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

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
  def handle_info({type, %Hasty.Addresses.Address{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :addresses, list_addresses(socket.assigns.current_scope), reset: true)}
  end

  defp list_addresses(current_scope) do
    Addresses.list_addresses(current_scope)
  end
end
