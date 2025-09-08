defmodule HastyWeb.BusLive.Form do
  use HastyWeb, :live_view

  alias Hasty.Buses
  alias Hasty.Buses.Bus
  alias Hasty.Lines

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage bus records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="bus-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:plate]} type="text" label="Plate" />
        <.input field={@form[:capacity]} type="number" label="Capacity" />
        <.input
          field={@form[:line_id]}
          type="select"
          label="Line"
          options={Enum.map(@lines, fn line -> {line.name, line.id} end)}
         />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Bus</.button>
          <.button navigate={return_path(@current_scope, @return_to, @bus)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """ 
  end

  @impl true
  def mount(params, _session, socket) do
    lines = Lines.list_lines
    {:ok,
      socket
      |> assign(:lines, lines)
      |> assign(:return_to, return_to(params["return_to"]))
      |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    bus = Buses.get_bus(id)

    socket
    |> assign(:page_title, "Edit Bus")
    |> assign(:bus, bus)
    |> assign(:form, to_form(Buses.change_bus(bus)))
  end

  defp apply_action(socket, :new, _params) do
    bus = %Bus{}

    socket
    |> assign(:page_title, "New Bus")
    |> assign(:bus, bus)
    |> assign(:form, to_form(Buses.change_bus(bus)))
  end

  @impl true
  def handle_event("validate", %{"bus" => bus_params}, socket) do
    changeset = Buses.change_bus(socket.assigns.bus, bus_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"bus" => bus_params}, socket) do
    save_bus(socket, socket.assigns.live_action, bus_params)
  end

  defp save_bus(socket, :edit, bus_params) do
    case Buses.update_bus(socket.assigns.bus, bus_params)  do
      {:ok, bus} ->
        {:noreply,
          socket
          |> put_flash(:info, "Bus updated successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bus)
          )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_bus(socket, :new, bus_params) do
    case Buses.create_bus(bus_params) do
      {:ok, bus} ->
        {:noreply,
          socket
          |> put_flash(:info, "Bus created successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, bus)
          )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _bus), do: ~p"/buses"
  defp return_path(_scope, "show", bus), do: ~p"/buses/#{bus}"
end
