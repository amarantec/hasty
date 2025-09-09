defmodule HastyWeb.BusLive.BusStopShow do
  use HastyWeb, :live_view 

  alias Hasty.BusStops

  @impl true
  def render(assigns) do
    ~H""" 
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Bus Stop - {@bus_stop.name}
        <:subtitle>This is a bus record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/bus-stops"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.button variant="primary" navigate={~p"/admin/bus-stops/#{@bus_stop}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> Edit Bus Stop
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.list>
        <:item title="Bus Stop Name">{@bus_stop.name}</:item>
        <:item title="Bus Stop Latitude">{@bus_stop.latitude}</:item>
        <:item title="Bus Stop Longitude">{@bus_stop.longitude}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "Show Bus Stop")
      |> assign(:bus_stop, BusStops.get_bus_stop(id))}
  end

  @impl true
  def handle_info(
    {:updated, %Hasty.Buses.BusStop{id: id} = bus_stop},
    %{assigns: %{bus_stop: %{id: id}}} = socket
    ) do
    {:noreply, assign(socket, :bus_stop, bus_stop)}
  end

  def handle_info(
    {:deleted, %Hasty.Buses.BusStop{id: id}},
    %{assigns: %{bus_stop: %{id: id}}} = socket
    ) do
    {:noreply,
      socket
      |> put_flash(:error, "The current bus was deleted.")
      |> push_navigate(to: ~p"/bus-stops")}
  end

  def handle_info({type, %Hasty.Buses.BusStop{}}, socket)
    when type in [:created, :updated, :deleted] do
      {:noreply, socket}
  end
end
