defmodule Konew.Mailer do
  use Swoosh.Mailer, otp_app: :konew

  def default_from do
    {"Konew", "noreply@lamiau.dev"}
  end
end
