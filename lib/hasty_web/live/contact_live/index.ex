defmodule HastyWeb.ContactLive.Index do
  use HastyWeb, :live_view

  alias Hasty.Contacts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Contacts
        <:actions>
          <.button navigate={~p"/users/settings"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/contacts/new"}>
            <.icon name="hero-plus" /> New Contact
          </.button>
        </:actions>
      </.header>

      <.table
        id="contacts"
        rows={@streams.contacts}
        row_click={fn {_id, contact} -> JS.navigate(~p"/contacts/#{contact}") end}
      >
        <:col :let={{_id, contact}} label="DDI">{contact.ddi}</:col>
        <:col :let={{_id, contact}} label="DDD">{contact.ddd}</:col>
        <:col :let={{_id, contact}} label="Phone Number">{contact.phone_number}</:col>
        <:action :let={{_id, contact}}>
          <div class="sr-only">
            <.link navigate={~p"/contacts/#{contact}"}>Show</.link>
          </div>
          <.link navigate={~p"/contacts/#{contact}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, contact}}>
          <.link
            phx-click={JS.push("delete", value: %{id: contact.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Contacts.subscribe_contacts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Contacts")
     |> stream(:contacts, list_contacts(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact = Contacts.get_contact!(socket.assigns.current_scope, id)
    {:ok, _} = Contacts.delete_contact(socket.assigns.current_scope, contact)

    {:noreply, stream_delete(socket, :contacts, contact)}
  end

  @impl true
  def handle_info({type, %Hasty.Contacts.Contact{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :contacts, list_contacts(socket.assigns.current_scope), reset: true)}
  end

  defp list_contacts(current_scope) do
    Contacts.list_contacts(current_scope)
  end
end
