defmodule HastyWeb.LineLive.Show do
  use HastyWeb, :live_view 

  alias Hasty.Lines
  alias Hasty.LineStops

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Line - {@line.name}
        <:subtitle>This is a line record from your database</:subtitle>
        <:actions>
          <.button navigate={~p"/lines"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@line.name}</:item>
        <:item title="Flat Fare">{@line.flat_fare}</:item>
        <:item title="Base Price">{@line.base_price}</:item>
      </.list>

      <div class="divider" />

      <p>Line Stops Orders</p>
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
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "Show Line")
      |> stream(:line_stops, LineStops.list_line_stops_for_line(id))
      |> assign(:line, Lines.get_line(id))}
  end
end
