defmodule HastyWeb.BusLive.Show do
  use HastyWeb, :live_view 

  alias Hasty.Buses

  @impl true
  def render(assigns) do
    ~H""" 
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Bus {@bus.plate}
        <:subtitle>This is a bus record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/buses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.button variant="primary" navigate={~p"/admin/buses/#{@bus}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> Edit bus
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.list>
        <:item title="Bus line">{@bus.line.name}</:item>
        <:item title="Bus Plate">{@bus.plate}</:item>
        <:item title="Bus Capacity">{@bus.capacity}</:item>
        <:item title="Fare">${@bus.line.base_price}</:item>
      </.list>

      <div class="divider" />
      
      <.button variant="primary">Buy Ticket</.button>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "Show Bus")
      |> assign(:bus, Buses.get_bus_with_line(id))}
  end

  @impl true
  def handle_info(
    {:updated, %Hasty.Buses.Bus{id: id} = bus},
    %{assigns: %{bus: %{id: id}}} = socket
    ) do
    {:noreply, assign(socket, :bus, bus)}
  end

  def handle_info(
    {:deleted, %Hasty.Buses.Bus{id: id}},
    %{assigns: %{bus: %{id: id}}} = socket
    ) do
    {:noreply,
      socket
      |> put_flash(:error, "The current bus was deleted.")
      |> push_navigate(to: ~p"/buses")}
  end

  def handle_info({type, %Hasty.Buses.Bus{}}, socket)
    when type in [:created, :updated, :deleted] do
      {:noreply, socket}
  end
end
