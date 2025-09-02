defmodule HastyWeb.AddressLive.Show do
  use HastyWeb, :live_view

  alias Hasty.Addresses

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
        <:item title="Street">{@address.street}</:item>
        <:item title="Number">{@address.number}</:item>
        <:item title="City">{@address.city}</:item>
        <:item title="Neighborhood">{@address.neighborhood}</:item>
        <:item title="State">{@address.state}</:item>
        <:item title="Country">{@address.country}</:item>
        <:item title="ZIP Code">{@address.zip_code}</:item>
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
        {:updated, %Hasty.Addresses.Address{id: id} = address},
        %{assigns: %{address: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :address, address)}
  end

  def handle_info(
        {:deleted, %Hasty.Addresses.Address{id: id}},
        %{assigns: %{address: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current address was deleted.")
     |> push_navigate(to: ~p"/addresses")}
  end

  def handle_info({type, %Hasty.Addresses.Address{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
