defmodule HastyWeb.LineLive.LineStopForm do
  use HastyWeb, :live_view

  alias Hasty.Lines
  alias Hasty.LineStops
  alias Hasty.Lines.LineStop
  alias Hasty.BusStops

  @impl true
  def render(assigns) do
    ~H"""
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage line stops records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="line_stop-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:order]} type="number" label="Order" /> 
          <.input
            field={@form[:line_id]}
            type="select"
            label="Line"
            options={Enum.map(@lines, fn line -> {line.name, line.id} end)}
          />
          <.input
            field={@form[:bus_stop_id]}
            type="select"
            label="Bus Stop"
            options={Enum.map(@bus_stops, fn bus_stop -> {bus_stop.name, bus_stop.id} end)}
          />
          <footer>
            <.button phx-disable-with="Saving..." variant="primary">Save Line Stop</.button>
            <.button navigate={return_path(@current_scope, @return_to, @line_stop)}>Cancel</.button>
          </footer>
        </.form>
      </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    lines = Lines.list_lines
    bus_stops = BusStops.list_bus_stops
    {:ok,
      socket
      |> assign(:lines, lines)
      |> assign(:bus_stops, bus_stops)
      |> assign(:return_to, return_to(params["return_to"]))
      |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    line_stop = LineStops.get_line_stop(id)

    socket
    |> assign(:page_title, "Edit Line Stop")
    |> assign(:line_stop, line_stop)
    |> assign(:form, to_form(LineStops.change_line_stop(line_stop)))
  end

  defp apply_action(socket, :new, _params) do
    line_stop = %LineStop{}

    socket
    |> assign(:page_title, "New Line Stop")
    |> assign(:line_stop, line_stop)
    |> assign(:form, to_form(LineStops.change_line_stop(line_stop)))
  end

  @impl true
  def handle_event("validate", %{"line_stop" => line_stop_params}, socket) do
    changeset = LineStops.change_line_stop(socket.assigns.line_stop, line_stop_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"line_stop" => line_stop_params}, socket) do
    save_line_stop(socket, socket.assigns.live_action, line_stop_params)
  end

  defp save_line_stop(socket, :edit, line_stop_params) do
    case LineStops.update_line_stop(socket.assigns.line_stop, line_stop_params) do
      {:ok, line_stop} ->
        {:noreply,
          socket
          |> put_flash(:info, "Line Stop updated successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, line_stop)
          )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_line_stop(socket, :new, line_stop_params) do
    case LineStops.create_line_stop(line_stop_params) do
      {:ok, line_stop} ->
        {:noreply,
          socket
          |> put_flash(:info, "Line Stop created successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, line_stop)
          )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _line_stop), do: ~p"/line-stops"
  defp return_path(_scope, "show", line_stop), do: ~p"/line-stops/#{line_stop}"
end
