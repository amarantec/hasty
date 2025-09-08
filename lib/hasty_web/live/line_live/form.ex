defmodule HastyWeb.LineLive.Form do
  use HastyWeb, :live_view

  alias Hasty.Lines
  alias Hasty.Lines.Line

  @impl  true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      <:subtitle>Use this form to manage lines records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="line-form" phx-change="validate" phx-submit="save"> 
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:flat_fare]} type="checkbox" label="Flat Fare" />
        <.input field={@form[:base_price]} type="number" step="any" label="Base price" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Line</.button>
          <.button navigate={return_path(@current_scope, @return_to, @line)}>Cancel</.button>
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
    line = Lines.get_line(id)

    socket
    |> assign(:page_title, "Edit Line")
    |> assign(:line, line)
    |> assign(:form, to_form(Lines.change_line(line)))
  end

  defp apply_action(socket, :new, _params) do
    line = %Line{}

    socket
    |> assign(:page_title, "New Line")
    |> assign(:line, line)
    |> assign(:form, to_form(Lines.change_line(line)))
  end

  @impl true
  def handle_event("validate", %{"line" => line_params}, socket) do
    changeset = Lines.change_line(socket.assigns.line, line_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"line" => line_params}, socket) do
    save_line(socket, socket.assigns.live_action, line_params)
  end

  defp save_line(socket, :edit, line_params) do
    case Lines.update_line(socket.assigns.line, line_params)  do
      {:ok, line} ->
        {:noreply,
          socket
          |> put_flash(:info, "Line updated successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, line)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_line(socket, :new, line_params) do
    case Lines.create_line(line_params) do
      {:ok, line} ->
        {:noreply,
          socket
          |> put_flash(:info, "Line created successfully")
          |> push_navigate(
            to: return_path(socket.assigns.current_scope, socket.assigns.return_to, line)
          )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _line), do: ~p"/lines"
  defp return_path(_scope, "show", line), do: ~p"/lines/#{line}"
end
