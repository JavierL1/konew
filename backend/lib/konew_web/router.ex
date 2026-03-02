defmodule KonewWeb.Router do
  use KonewWeb, :router

  import KonewWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KonewWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug KonewWeb.ApiAuth
  end

  pipeline :ensure_api_authenticated do
    plug KonewWeb.ApiAuth, :ensure_authenticated
  end

  # --- Public Browser Routes ---
  scope "/", KonewWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # --- Protected Browser Routes ---
  scope "/", KonewWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/drawings", DrawingController, :index
    get "/drawings/raw/:id", DrawingController, :show_image, as: :drawing_raw
    get "/draw", DrawingController, :new

    post "/drawings", DrawingController, :create
    post "/users/update-password", UserSessionController, :update_password

    live_session :require_authenticated_user,
      on_mount: [{KonewWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end
  end

  # --- Auth/Session Management ---
  scope "/", KonewWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{KonewWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  # --- API Routes ---

  # Public API
  scope "/api", KonewWeb do
    pipe_through :api
    post "/log_in", UserSessionController, :create
  end

  # Protected API
  scope "/api", KonewWeb do
    pipe_through [:api, :ensure_api_authenticated]
    post "/drawings", DrawingController, :create
  end

  # --- Development Tools ---
  if Application.compile_env(:konew, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: KonewWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
