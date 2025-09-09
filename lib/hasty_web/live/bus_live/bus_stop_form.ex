defmodule HastyWeb.BusLive.BusStopForm do
  use HastyWeb, :live_view

  alias Hasty.Buses.BusStop
  alias Hasty.BusStops

  @impl true
  def render(assigns) do
    ~H"""
      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage bus stops records in your database.</:subtitle>
        </.header>
        <.form for={@form} id="bus_stop-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:latitude]} type="number" step="any" label="Latitude" />
          <.input field={@form[:longitude]} type="number" step="any" label="Longitude" />
          <footer>
            <.button phx-disable-with="Saving..." variant="primary">Save Bus Stop</.button>
            <.button navigate={return_path(@current_scope, @return_to, @bus_stop)}>Cancel</.button>
          </footer>
       </.form>
      </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
      socket
      |> assign(:return_to, return_to(params["return_to"]))
      |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    bus_stop = BusStops.get_bus_stop(id)

    socket
    |> assign(:page_title, "Edit Bus Stop")
    |> assign(:bus_stop, bus_stop)
    |> assign(:form, to_form(BusStops.change_bus_stop(bus_stop)))
  end

  defp apply_action(socket, :new, _params) do
    bus_stop = %BusStop{}

    socket
    |> assign(:page_title, "New Bus Stop")
    |> assign(:bus_stop, bus_stop)
    |> assign(:form, to_form(BusStops.change_bus_stop(bus_stop)))
  end

  @impl true
  def handle_event("validate", %{"bus_stop" => bus_stop_params}, socket) do
    changeset = BusStops.change_bus_stop(socket.assigns.bus_stop, bus_stop_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"bus_stop" => bus_stop_params}, socket) do
    save_bus_stop(socket, socket.assigns.live_action, bus_stop_params)
  end

  defp save_bus_stop(socket, :edit, bus_stop_params) do
    case BusStops.update_bus_stop(socket.assigns.bus_stop, bus_stop_params)  do
      {:ok, bus_stop} ->
        {:noreply,
          socket
          |> put_flash(:info, "Bus Stop updated successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bus_stop)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bus_stop(socket, :new, bus_stop_params) do
    case BusStops.create_bus_stop(bus_stop_params) do
      {:ok, bus_stop} ->
        {:noreply,
          socket
          |> put_flash(:info, "Bus Stop created successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bus_stop)
          )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _bus_stop), do: ~p"/bus-stops"
  defp return_path(_scope, "show", bus_stop), do: ~p"/bus-stops/#{bus_stop}"
end
