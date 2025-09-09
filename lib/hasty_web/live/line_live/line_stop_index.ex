defmodule HastyWeb.LineLive.LineStopIndex do
  use HastyWeb, :live_view

  alias Hasty.LineStops

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Available Line Stops
        <:actions>
          <.button navigate={~p"/bus-stops"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.button variant="primary" navigate={~p"/admin/line-stops/new"}>
              <.icon name="hero-plus" /> New Line Stop
            </.button>
          <% end %>
        </:actions>
      </.header>

      <div class="divider" />

      <.table
        id="line_stops"
        rows={@streams.line_stops}
        row_click={fn {_id, line_stop} -> JS.navigate(~p"/line-stops/#{line_stop}") end}
      >
        <:col :let={{_id, line_stop}} label="Line Stop Order">{line_stop.order}</:col>
        <:action :let={{_id, line_stop}}>
          <div class="sr-only">
            <.link navigate={~p"/line-stops/#{line_stop}"}>Show</.link>
          </div>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.link navigate={~p"/admin/line-stops/#{line_stop}/edit"}>Edit</.link>
          <% end %>
        </:action>
        <:action :let={{id, line_stop}}>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.link
              phx-click={JS.push("delete", value: %{id: line_stop.id}) |> hide("##{id}")}
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
      |> assign(:page_title, "List Available Line Stops")
      |> stream(:line_stops, LineStops.list_line_stops)}
  end
end
