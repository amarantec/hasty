defmodule HastyWeb.AddressLive.Form do
  use HastyWeb, :live_view

  alias Hasty.Addresses
  alias Hasty.Addresses.Address

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage address records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="address-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:street]} type="text" label="Street" />
        <.input field={@form[:number]} type="text" label="Number" />
        <.input field={@form[:city]} type="text" label="City" />
        <.input field={@form[:neighborhood]} type="text" label="Neighborhood" />
        <.input field={@form[:state]} type="text" label="State" />
        <.input field={@form[:country]} type="text" label="Country" />
        <.input field={@form[:zip_code]} type="text" label="ZIP Code" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Address</.button>
          <.button navigate={return_path(@current_scope, @return_to, @address)}>Cancel</.button>
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
    address = Addresses.get_address!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Address")
    |> assign(:address, address)
    |> assign(:form, to_form(Addresses.change_address(socket.assigns.current_scope, address)))
  end

  defp apply_action(socket, :new, _params) do
    address = %Address{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Address")
    |> assign(:address, address)
    |> assign(:form, to_form(Addresses.change_address(socket.assigns.current_scope, address)))
  end

  @impl true
  def handle_event("validate", %{"address" => address_params}, socket) do
    changeset = Addresses.change_address(socket.assigns.current_scope, socket.assigns.address, address_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"address" => address_params}, socket) do
    save_address(socket, socket.assigns.live_action, address_params)
  end

  defp save_address(socket, :edit, address_params) do
    case Addresses.update_address(socket.assigns.current_scope, socket.assigns.address, address_params) do
      {:ok, address} ->
        {:noreply,
         socket
         |> put_flash(:info, "Address updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, address)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_address(socket, :new, address_params) do
    case Addresses.create_address(socket.assigns.current_scope, address_params) do
      {:ok, address} ->
        {:noreply,
         socket
         |> put_flash(:info, "Address created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, address)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _address), do: ~p"/addresses"
  defp return_path(_scope, "show", address), do: ~p"/addresses/#{address}"
end
