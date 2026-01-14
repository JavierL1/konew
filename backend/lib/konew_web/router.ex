defmodule KonewWeb.Router do
  use KonewWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {KonewWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", KonewWeb do
    pipe_through(:browser)

    get("/", PageController, :home)

    get("/drawings", DrawingController, :index)
    get("/drawings/raw/:id", DrawingController, :show_image, as: :drawing_raw)
  end

  scope "/api", KonewWeb do
    pipe_through(:api)

    post("/drawings", DrawingController, :create)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:konew, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: KonewWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
