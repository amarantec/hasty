defmodule HastyWeb.BusLive.Index do
  use HastyWeb, :live_view

  alias Hasty.Buses

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Available Bus
        <:actions>
          <.button navigate={~p"/"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.button variant="primary" navigate={~p"/admin/buses/new"}>
              <.icon name="hero-plus" /> New Bus
            </.button>
          <% end %>
        <.button variant="primary" navigate={~p"/lines"}> Lines </.button>
        </:actions>
      </.header>

      <div class="divider" />

      <.table
        id="buses"
        rows={@streams.buses}
        row_click={fn {_id, bus} -> JS.navigate(~p"/buses/#{bus}") end}
      >
        <:col :let={{_id, bus}} label="Test">{bus.plate}</:col>
        <:action :let={{_id, bus}}>
          <div class="sr-only">
            <.link navigate={~p"/buses/#{bus}"}>Show</.link>
          </div>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "List Available Buses")
      |> stream(:buses, Buses.list_buses)}
  end
end
