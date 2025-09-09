defmodule HastyWeb.LineLive.Index do
  use HastyWeb, :live_view

  alias Hasty.Lines

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing available Lines
        <:actions>
          <.button navigate={~p"/buses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.button variant="primary" navigate={~p"/admin/lines/new"}>
              <.icon name="hero-plus" /> New Line
            </.button>
          <% end %>
        </:actions>
      </.header>
      <.table
        id="lines"
        rows={@streams.lines}
        row_click={fn {_, line} -> JS.navigate(~p"/lines/#{line}") end}
      >
        <:col :let={{_id, line}} label="Name">{line.name}</:col>
        <:col :let={{_id, line}} label="Flat Fare">{line.flat_fare}</:col>
        <:col :let={{_id, line}} label="Base Price">{line.base_price}</:col>
        <:action :let={{_id, line}}>
          <div class="sr-only">
            <.link navigate={~p"/lines/#{line}"}>Show</.link>
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
      |> assign(:page_title, "List Lines")
      |> stream(:lines, Lines.list_lines)}
  end
end
