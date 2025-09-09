defmodule HastyWeb.LineLive.LineStopShow do
  use HastyWeb, :live_view 

  alias Hasty.LineStops

  @impl true
  def render(assigns) do
    ~H""" 
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Line Stop  {@line_stop.order}
        <:subtitle>This is a line stop record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/lines/#{@line_stop.line}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope && @current_scope.user.role == "admin" do %>
            <.button variant="primary" navigate={~p"/admin/line-stops/#{@line_stop}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> Edit Line Stop
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.list>
        <:item title="Line Stop Order">{@line_stop.order}</:item>
        <:item title="Line Name">{@line_stop.line.name}</:item>
        <:item title="Bus Stop Name">{@line_stop.bus_stop.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "Show Line Stop")
      |> assign(:line_stop, LineStops.get_line_stop_full_info(id))}
  end

  @impl true
  def handle_info(
    {:updated, %Hasty.Lines.LineStop{id: id} = line_stop},
    %{assigns: %{line_stop: %{id: id}}} = socket
    ) do
    {:noreply, assign(socket, :line_stop, line_stop)}
  end

  def handle_info(
    {:deleted, %Hasty.Lines.LineStop{id: id}},
    %{assigns: %{line_stop: %{id: id}}} = socket
    ) do
    {:noreply,
      socket
      |> put_flash(:error, "The current line stop was deleted.")
      |> push_navigate(to: ~p"/line-stops")}
  end

  def handle_info({type, %Hasty.Lines.LineStop{}}, socket)
    when type in [:created, :updated, :deleted] do
      {:noreply, socket}
  end
end
