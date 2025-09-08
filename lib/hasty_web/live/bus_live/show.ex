defmodule HastyWeb.BusLive.Show do
  use HastyWeb, :live_view 

  alias Hasty.Buses

  @impl true
  def render(assigns) do
    ~H""" 
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Bus {@bus.plate}
        <:subtitle>Test show</:subtitle>
        <:actions>
          <.button navigate={~p"/buses"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Plate">{@bus.plate}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "Show Bus")
      |> assign(:bus, Buses.get_bus(id))}
  end
end
