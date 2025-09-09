defmodule HastyWeb.BusLive.BusStopIndex do
  use HastyWeb, :live_view

  alias Hasty.BusStops

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Available Bus Stops
        <:actions>
          <.button navigate={~p"/buses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.button variant="primary" navigate={~p"/admin/bus-stops/new"}>
              <.icon name="hero-plus" /> New Bus Stop
            </.button>
          <% end %>
        <.button variant="primary" navigate={~p"/line-stops"}> Line Stops</.button>
        </:actions>
      </.header>

      <div class="divider" />

      <.table
        id="bus_stops"
        rows={@streams.bus_stops}
        row_click={fn {_id, bus_stop} -> JS.navigate(~p"/bus-stops/#{bus_stop}") end}
      >
        <:col :let={{_id, bus_stop}} label="Bus Stop Name">{bus_stop.name}</:col>
        <:col :let={{_id, bus_stop}} label="Bus Stop Latitude">{bus_stop.latitude}</:col>
        <:col :let={{_id, bus_stop}} label="Bus Stop Longitude">{bus_stop.longitude}</:col>
        <:action :let={{_id, bus_stop}}>
          <div class="sr-only">
            <.link navigate={~p"/bus-stops/#{bus_stop}"}>Show</.link>
          </div>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.link navigate={~p"/admin/bus-stops/#{bus_stop}/edit"}>Edit</.link>
          <% end %>
        </:action>
        <:action :let={{id, bus_stop}}>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.link
              phx-click={JS.push("delete", value: %{id: bus_stop.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          <% end %>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "List Available Bus Stops")
      |> stream(:bus_stops, BusStops.list_bus_stops)}
  end
end
