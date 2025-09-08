defmodule HastyWeb.Router do
  use HastyWeb, :router

  import HastyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HastyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :require_admin do
    plug :require_authenticated_user
    plug :ensure_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HastyWeb do
    pipe_through [:browser]

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", HastyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hasty, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HastyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", HastyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HastyWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
      
      # Contact
      live "/contacts", ContactLive.Index, :index
      live "/contacts/new", ContactLive.Form, :new
      live "/contacts/:id", ContactLive.Show, :show
      live "/contacts/:id/edit", ContactLive.Form, :edit

      # Addresses
      live "/addresses", AddressLive.Index, :index
      live "/addresses/new", AddressLive.Form, :new
      live "/addresses/:id", AddressLive.Show, :show
      live "/addresses/:id/edit", AddressLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", HastyWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{HastyWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new

      # Bus
      live "/buses", BusLive.Index, :index
      #live "/admin/buses/new", BusLive.Form, :new
      live "/buses/:id", BusLive.Show, :show
      live "/admin/buses/:id/edit", BusLive.Form, :edit

      # Line
      live "/lines", LineLive.Index, :index
      live "/lines/:id", LineLive.Show, :show
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  scope "/admin", HastyWeb do
    pipe_through [:browser, :require_admin]
    live_session :require_admin,
      on_mount: [
        {HastyWeb.UserAuth, :require_authenticated}
      ] do
        live "/buses/new", BusLive.Form, :new
        live "/lines/new", LineLive.Form, :new
      end
  end
end
