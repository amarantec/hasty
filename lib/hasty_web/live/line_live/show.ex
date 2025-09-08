defmodule HastyWeb.LineLive.Show do
  use HastyWeb, :live_view 

  alias Hasty.Lines

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Line {@line.id}
        <:subtitle>This is a line record from your database</:subtitle>
        <:actions>
          <.button navigate={~p"/lines"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@line.name}</:item>
      </.list>
    </Layouts.app>
    """ 
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
      socket
      |> assign(:page_title, "Show Line")
      |> assign(:line, Lines.get_line(id))}
  end
end
